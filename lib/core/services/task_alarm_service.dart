import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'mobile_notification_service.dart';

/// Central In-App and Background Alarm Manager responsible for tracking,
/// scheduling, loud ringtone playback, mobile notifications, snoozing,
/// and managing task start alarms across foreground and background states.
class TaskAlarmService {
  TaskAlarmService._();
  static final TaskAlarmService instance = TaskAlarmService._();

  static const String _prefDismissedAlarmsKey = 'in_app_alarm_dismissed_keys';

  Timer? _tickerTimer;
  Timer? _soundLoopTimer;

  bool get isInTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  // Registered tasks mapped by task.id
  final Map<String, Task> _registeredTasks = {};

  // Dismissed alarm instances: set of "taskId_date_hour_minute"
  final Set<String> _dismissedAlarmKeys = {};

  // Snoozed alarms: taskId -> snooze target DateTime
  final Map<String, DateTime> _snoozedUntil = {};

  // State notifiers for UI
  final ValueNotifier<Task?> ringingAlarmNotifier = ValueNotifier<Task?>(null);
  final ValueNotifier<List<Task>> upcomingAlarmsNotifier =
      ValueNotifier<List<Task>>([]);

  final StreamController<Task> _alarmTriggeredStream =
      StreamController<Task>.broadcast();
  Stream<Task> get onAlarmTriggered => _alarmTriggeredStream.stream;

  void Function(Task updatedTask)? onTaskUpdatedCallback;

  bool _isInitialized = false;
  bool _isSoundMuted = false;

  bool get isRinging => ringingAlarmNotifier.value != null;
  Task? get activeAlarmTask => ringingAlarmNotifier.value;
  bool get isSoundMuted => _isSoundMuted;

  set isSoundMuted(bool value) {
    _isSoundMuted = value;
    if (_isSoundMuted) {
      _stopNativeRingtone();
    } else if (isRinging) {
      _startNativeRingtone();
    }
  }

  /// Initialize alarm service and load persisted dismissed alarms
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Initialize system-level mobile notifications (for closed/background alarms)
    try {
      await MobileNotificationService.instance.init(
        onNotificationSelected: (taskId) {
          if (taskId != null && _registeredTasks.containsKey(taskId)) {
            triggerAlarm(_registeredTasks[taskId]!);
          }
        },
      );
    } catch (e) {
      debugPrint('[TaskAlarmService] Mobile notification init warning: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDismissed = prefs.getStringList(_prefDismissedAlarmsKey);
      if (savedDismissed != null) {
        _dismissedAlarmKeys.addAll(savedDismissed);
      }
    } catch (e) {
      debugPrint('[TaskAlarmService] Warning loading prefs: $e');
    }

    // Start background ticker checking every 2 seconds (except in test runner)
    if (!isInTest) {
      _tickerTimer?.cancel();
      _tickerTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        checkAlarms();
      });
    }
  }

  /// Synchronize current tasks from TaskBloc or repository
  void syncTasks(List<Task> tasks) {
    final currentIds = <String>{};

    for (final task in tasks) {
      currentIds.add(task.id);
      if (task.hasActiveAlarm) {
        _registeredTasks[task.id] = task;

        // Schedule system notification so alarm rings even if app is closed
        final triggerTime = _getTargetTriggerTime(task);
        if (triggerTime != null && triggerTime.isAfter(DateTime.now())) {
          MobileNotificationService.instance.scheduleTaskAlarm(
            task: task,
            scheduledTime: triggerTime,
          );
        }
      } else {
        _registeredTasks.remove(task.id);
        MobileNotificationService.instance.cancelAlarmNotification(task.id);
      }
    }

    // Cancel alarms for deleted tasks
    _registeredTasks.removeWhere((id, _) {
      if (!currentIds.contains(id)) {
        MobileNotificationService.instance.cancelAlarmNotification(id);
        return true;
      }
      return false;
    });

    _updateUpcomingAlarms();
  }

  void _updateUpcomingAlarms() {
    final now = DateTime.now();
    final list = _registeredTasks.values.where((t) {
      final target = _getTargetTriggerTime(t);
      if (target == null) return false;
      // Show alarms that are in future or due recently (within past 2 hours)
      return target.isAfter(now.subtract(const Duration(hours: 2)));
    }).toList();

    list.sort((a, b) {
      final timeA = _getTargetTriggerTime(a) ?? DateTime(2099);
      final timeB = _getTargetTriggerTime(b) ?? DateTime(2099);
      return timeA.compareTo(timeB);
    });

    upcomingAlarmsNotifier.value = list;
  }

  DateTime? _getTargetTriggerTime(Task task) {
    if (_snoozedUntil.containsKey(task.id)) {
      return _snoozedUntil[task.id];
    }
    return task.scheduledAlarmTime;
  }

  String _generateAlarmInstanceKey(Task task, DateTime triggerTime) {
    return '${task.id}_${triggerTime.year}_${triggerTime.month}_${triggerTime.day}_${triggerTime.hour}_${triggerTime.minute}';
  }

  /// Check for alarms that should start ringing
  void checkAlarms() {
    if (isRinging) return; // Wait until current alarm is resolved

    final now = DateTime.now();

    for (final task in _registeredTasks.values) {
      if (!task.hasActiveAlarm) continue;

      final triggerTime = _getTargetTriggerTime(task);
      if (triggerTime == null) continue;

      final key = _generateAlarmInstanceKey(task, triggerTime);
      if (_dismissedAlarmKeys.contains(key)) continue;

      // Check if time has arrived (within a 30-minute window)
      final difference = now.difference(triggerTime);
      final isDue = (now.isAfter(triggerTime) || now.isAtSameMomentAs(triggerTime)) &&
          difference.inMinutes <= 30 &&
          difference.inHours >= 0;

      if (isDue) {
        triggerAlarm(task);
        break;
      }
    }
  }

  /// Triggers alarm ringing for a task
  void triggerAlarm(Task task) {
    ringingAlarmNotifier.value = task;
    _alarmTriggeredStream.add(task);

    // Show high-priority mobile heads-up notification with action buttons
    MobileNotificationService.instance.showRingingNotification(task: task);

    _startRingtoneLoop();
  }

  /// Manually triggers a test alarm for UI testing & verification
  void triggerTestAlarm([Task? testTask]) {
    final taskToRing = testTask ??
        Task(
          id: 'test-alarm-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Design Review & Sprint Planning',
          subtitle: 'Digital Product Design',
          description:
              'Review high-fidelity interactive screens and outline upcoming deliverables.',
          category: 'Design',
          dueDate: DateTime.now(),
          dueTime: 'Now',
          timeRange: 'Now - Next 1 Hour',
          createdAt: DateTime.now(),
          isAlarmEnabled: true,
          status: 'In Process',
        );

    triggerAlarm(taskToRing);
  }

  void _startRingtoneLoop() {
    _soundLoopTimer?.cancel();

    // Start real native alarm ringtone audio
    _startNativeRingtone();

    // Immediate haptic & system pulse
    _playAlertPulse();

    // Repeating haptic / pulse pattern every 850ms in production
    if (!isInTest) {
      _soundLoopTimer = Timer.periodic(const Duration(milliseconds: 850), (_) {
        _playAlertPulse();
      });
    }
  }

  static const MethodChannel _ringtoneChannel =
      MethodChannel('com.example.todoapp/ringtone');

  void _startNativeRingtone() {
    if (isInTest || _isSoundMuted) return;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        _ringtoneChannel.invokeMethod('playAlarm');
      } else {
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('[TaskAlarmService] Error playing native ringtone: $e');
    }
  }

  void _stopNativeRingtone() {
    if (isInTest) return;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        _ringtoneChannel.invokeMethod('stopAlarm');
      }
    } catch (e) {
      debugPrint('[TaskAlarmService] Error stopping native ringtone: $e');
    }
  }

  void _playAlertPulse() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void _stopRingtoneLoop() {
    _soundLoopTimer?.cancel();
    _soundLoopTimer = null;
    _stopNativeRingtone();
  }

  /// Stops all active timers, ringtones, and ringing dialogs
  void stop() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _stopRingtoneLoop();
    ringingAlarmNotifier.value = null;
  }

  /// Snooze alarm for given minutes (default 5 minutes)
  void snooze(Task task, {int minutes = 5}) {
    _stopRingtoneLoop();
    final snoozeTarget = DateTime.now().add(Duration(minutes: minutes));
    _snoozedUntil[task.id] = snoozeTarget;

    // Reschedule mobile notification so device rings even if app gets closed
    MobileNotificationService.instance.scheduleTaskAlarm(
      task: task,
      scheduledTime: snoozeTarget,
    );

    // Reset ringing state
    ringingAlarmNotifier.value = null;
    _updateUpcomingAlarms();
  }

  /// Dismiss alarm for this scheduled instance
  Future<void> dismiss(Task task) async {
    _stopRingtoneLoop();
    _snoozedUntil.remove(task.id);

    final triggerTime = _getTargetTriggerTime(task) ?? DateTime.now();
    final key = _generateAlarmInstanceKey(task, triggerTime);
    _dismissedAlarmKeys.add(key);

    // Cancel mobile notification
    await MobileNotificationService.instance.cancelAlarmNotification(task.id);

    ringingAlarmNotifier.value = null;
    _updateUpcomingAlarms();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefDismissedAlarmsKey,
        _dismissedAlarmKeys.toList(),
      );
    } catch (e) {
      debugPrint('[TaskAlarmService] Error saving dismissed keys: $e');
    }
  }

  /// Mark task as started now, update status, and dismiss ringing alarm
  Future<void> startTaskNow(
    Task task, {
    void Function(Task updatedTask)? onUpdateTask,
  }) async {
    await dismiss(task);

    // Update status to 'On going' and disable alarm so it doesn't re-ring
    final updated = task.copyWith(
      status: 'On going',
      isAlarmEnabled: false,
      hasReminder: false,
    );

    _registeredTasks[task.id] = updated;
    (onUpdateTask ?? onTaskUpdatedCallback)?.call(updated);
  }

  /// Dismiss alarm directly by taskId (e.g. from notification action button)
  Future<void> dismissByTaskId(String taskId) async {
    final task = _registeredTasks[taskId] ?? activeAlarmTask;
    if (task != null) {
      await dismiss(task);
    } else {
      _stopRingtoneLoop();
      _snoozedUntil.remove(taskId);
      final now = DateTime.now();
      _dismissedAlarmKeys.add('${taskId}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}');
      await MobileNotificationService.instance.cancelAlarmNotification(taskId);
      ringingAlarmNotifier.value = null;
      _updateUpcomingAlarms();
    }
  }

  /// Snooze alarm directly by taskId (e.g. from notification action button)
  void snoozeByTaskId(String taskId, {int minutes = 5}) {
    final task = _registeredTasks[taskId] ?? activeAlarmTask;
    if (task != null) {
      snooze(task, minutes: minutes);
    } else {
      _stopRingtoneLoop();
      ringingAlarmNotifier.value = null;
      _updateUpcomingAlarms();
    }
  }

  /// Start task directly by taskId (e.g. from notification action button)
  Future<void> startTaskNowByTaskId(String taskId) async {
    final task = _registeredTasks[taskId] ?? activeAlarmTask;
    if (task != null) {
      await startTaskNow(task);
    } else {
      await dismissByTaskId(taskId);
    }
  }

  /// Open/bring up ringing dialog by taskId (e.g. tapped notification banner)
  void openAlarmByTaskId(String taskId) {
    final task = _registeredTasks[taskId] ?? activeAlarmTask;
    if (task != null) {
      triggerAlarm(task);
    }
  }

  /// Toggle alarm on/off for a task
  void toggleAlarm({
    required Task task,
    required void Function(Task updatedTask) onUpdateTask,
    bool? enable,
    int? offsetMinutes,
  }) {
    final nextEnable = enable ?? !task.isAlarmEnabled;
    final nextOffset = offsetMinutes ?? task.alarmOffsetMinutes;

    final updated = task.copyWith(
      isAlarmEnabled: nextEnable,
      alarmOffsetMinutes: nextOffset,
    );

    if (nextEnable) {
      _registeredTasks[task.id] = updated;
      final triggerTime = _getTargetTriggerTime(updated);
      if (triggerTime != null && triggerTime.isAfter(DateTime.now())) {
        MobileNotificationService.instance.scheduleTaskAlarm(
          task: updated,
          scheduledTime: triggerTime,
        );
      }
    } else {
      _registeredTasks.remove(task.id);
      _snoozedUntil.remove(task.id);
      MobileNotificationService.instance.cancelAlarmNotification(task.id);
    }

    _updateUpcomingAlarms();
    onUpdateTask(updated);
  }
}
