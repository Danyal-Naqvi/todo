import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/tasks/domain/entities/task.dart';
import 'task_alarm_service.dart';

/// Top-level background notification response handler
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  // Always stop native alarm ringtone audio immediately
  const ringtoneChannel = MethodChannel('com.example.todoapp/ringtone');
  try {
    await ringtoneChannel.invokeMethod('stopAlarm');
  } catch (_) {}

  final taskId = response.payload;
  final actionId = response.actionId;
  if (taskId == null || taskId.isEmpty) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    if (actionId == 'dismiss' || actionId == 'start_now') {
      final saved = prefs.getStringList('in_app_alarm_dismissed_keys') ?? [];
      final now = DateTime.now();
      saved.add(
          '${taskId}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}');
      await prefs.setStringList('in_app_alarm_dismissed_keys', saved);
    } else if (actionId == 'snooze_5m') {
      final snoozeTarget = DateTime.now().add(const Duration(minutes: 5));
      await prefs.setString('snooze_$taskId', snoozeTarget.toIso8601String());
    }
  } catch (_) {}
}

/// Handles system-level mobile notifications and background scheduled alarms
/// that ring and wake up the device even when the app is completely closed.
class MobileNotificationService {
  MobileNotificationService._();
  static final MobileNotificationService instance =
      MobileNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String alarmChannelId = 'task_alarm_channel_v2';
  static const String alarmChannelName = 'Task Start Alarms';
  static const String alarmChannelDescription =
      'Loud ringing alarms and notifications for scheduled task start times';

  bool get isInTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  /// Handle user tap on notification body or action buttons
  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final taskId = response.payload;
    final actionId = response.actionId;

    if (taskId == null || taskId.isEmpty) return;

    if (actionId == 'dismiss') {
      await TaskAlarmService.instance.dismissByTaskId(taskId);
    } else if (actionId == 'snooze_5m') {
      TaskAlarmService.instance.snoozeByTaskId(taskId, minutes: 5);
    } else if (actionId == 'start_now') {
      await TaskAlarmService.instance.startTaskNowByTaskId(taskId);
    } else {
      // Tap on notification body itself without button
      TaskAlarmService.instance.openAlarmByTaskId(taskId);
    }
  }

  /// Initialize notification system and request permissions
  Future<void> init({
    void Function(String? taskId)? onNotificationSelected,
  }) async {
    if (_isInitialized || isInTest) return;

    try {
      // Initialize timezone database for precise scheduling
      tz.initializeTimeZones();

      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const linuxInit = LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
        linux: linuxInit,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          handleNotificationResponse(response);
          if (response.payload != null) {
            onNotificationSelected?.call(response.payload);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create high-priority alarm notification channel on Android
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        const alarmChannel = AndroidNotificationChannel(
          alarmChannelId,
          alarmChannelName,
          description: alarmChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

        await androidPlatform.createNotificationChannel(alarmChannel);

        // Request runtime permissions for Android 13+ (API 33+)
        try {
          await androidPlatform.requestNotificationsPermission();
        } catch (_) {}

        try {
          await androidPlatform.requestExactAlarmsPermission();
        } catch (_) {}
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('[MobileNotificationService] Initialization error: $e');
    }
  }

  int _notificationIdForTask(String taskId) {
    return taskId.hashCode.abs() % 100000000;
  }

  NotificationDetails _buildAlarmNotificationDetails({
    bool isRingingNow = false,
  }) {
    final androidDetails = AndroidNotificationDetails(
      alarmChannelId,
      alarmChannelName,
      channelDescription: alarmChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      ticker: isRingingNow ? 'Task starting now!' : 'Upcoming task',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Schedule a notification to ring when app is closed at [scheduledTime]
  Future<void> scheduleTaskAlarm({
    required Task task,
    required DateTime scheduledTime,
  }) async {
    if (isInTest) return;

    final now = DateTime.now();
    // If the scheduled time has already passed by more than 1 minute, don't schedule
    if (scheduledTime.isBefore(now.subtract(const Duration(minutes: 1)))) {
      return;
    }

    try {
      final id = _notificationIdForTask(task.id);
      final details = _buildAlarmNotificationDetails(isRingingNow: false);

      // Convert DateTime to TZDateTime in local time
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // If scheduled time is in the future, use zonedSchedule
      if (tzDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: '⏰ Task Starting: ${task.title}',
          body: task.description.trim().isNotEmpty
              ? task.description
              : 'Your task is scheduled to start right now! Tap to open.',
          scheduledDate: tzDateTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: task.id,
        );
      } else {
        // Trigger immediately if time is right now
        await showRingingNotification(task: task);
      }
    } catch (e) {
      debugPrint('[MobileNotificationService] Schedule error for ${task.id}: $e');
    }
  }

  /// Show an immediate high-priority alarm notification (when alarm is ringing)
  Future<void> showRingingNotification({required Task task}) async {
    if (isInTest) return;

    try {
      final id = _notificationIdForTask(task.id);
      final details = _buildAlarmNotificationDetails(isRingingNow: true);

      await _notificationsPlugin.show(
        id: id,
        title: '⏰ Task Starting Now: ${task.title}',
        body: task.description.trim().isNotEmpty
            ? task.description
            : 'Scheduled start time has arrived! Tap to start.',
        notificationDetails: details,
        payload: task.id,
      );
    } catch (e) {
      debugPrint('[MobileNotificationService] Immediate notification error: $e');
    }
  }

  /// Cancel scheduled notification for a task (when completed, dismissed, or alarm disabled)
  Future<void> cancelAlarmNotification(String taskId) async {
    if (isInTest) return;

    try {
      final id = _notificationIdForTask(taskId);
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('[MobileNotificationService] Cancel error for $taskId: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (isInTest) return;

    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
