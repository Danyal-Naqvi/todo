import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/core/services/mobile_notification_service.dart';
import 'package:todoapp/core/services/task_alarm_service.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/entities/task_priority.dart';
import 'package:todoapp/features/tasks/presentation/screens/active_alarms_screen.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_alarm_ringing_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';

class _FakeTaskRepo implements TaskRepository {
  final List<Task> _tasks = [];
  @override
  bool get isCloudSyncEnabled => false;
  @override
  Stream<List<Task>> watchTasks({required String userId}) =>
      Stream.value(_tasks);
  @override
  Future<List<Task>> getTasks({required String userId}) async => _tasks;
  @override
  Future<void> addTask(Task task, {required String userId}) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(Task task, {required String userId}) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
  }

  @override
  Future<void> deleteTask(String taskId, {required String userId}) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<void> toggleTaskStatus(String taskId, {required String userId}) async {}
  @override
  Future<void> toggleSubTaskStatus(String taskId, String subTaskId,
      {required String userId}) async {}
  @override
  Future<void> togglePinTask(String taskId, {required String userId}) async {}
  @override
  Future<void> clearCompletedTasks({required String userId}) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TaskAlarmService.instance.stop();
  });

  group('Task Alarm Model & Time Calculations', () {
    test('Task parses dueTime correctly into startDateTime and alarmTime', () {
      final task = Task(
        id: 'task-1',
        title: 'Morning Meeting',
        dueDate: DateTime(2026, 10, 8),
        dueTime: '10:45 am',
        createdAt: DateTime(2026, 10, 8),
        isAlarmEnabled: true,
        alarmOffsetMinutes: 5,
      );

      final start = task.startDateTime;
      expect(start, isNotNull);
      expect(start!.year, 2026);
      expect(start.month, 10);
      expect(start.day, 8);
      expect(start.hour, 10);
      expect(start.minute, 45);

      final alarmTime = task.scheduledAlarmTime;
      expect(alarmTime, isNotNull);
      // 10:45 minus 5 min = 10:40
      expect(alarmTime!.hour, 10);
      expect(alarmTime.minute, 40);

      expect(task.hasActiveAlarm, isTrue);
    });

    test('Completed or Canceled tasks do not have active alarm', () {
      final completed = Task(
        id: 'task-2',
        title: 'Completed Task',
        dueDate: DateTime.now(),
        dueTime: '09:00 am',
        createdAt: DateTime.now(),
        isAlarmEnabled: true,
        isCompleted: true,
      );
      expect(completed.hasActiveAlarm, isFalse);

      final canceled = Task(
        id: 'task-3',
        title: 'Canceled Task',
        dueDate: DateTime.now(),
        dueTime: '09:00 am',
        createdAt: DateTime.now(),
        isAlarmEnabled: true,
        status: 'Canceled',
      );
      expect(canceled.hasActiveAlarm, isFalse);
    });
  });

  group('TaskAlarmService Engine Tests', () {
    test('TaskAlarmService triggers test alarm and updates notifiers',
        () async {
      await TaskAlarmService.instance.initialize();

      expect(TaskAlarmService.instance.isRinging, isFalse);

      final task = Task(
        id: 'alarm-test-1',
        title: 'Sprint Planning',
        dueDate: DateTime.now(),
        dueTime: '11:00 am',
        createdAt: DateTime.now(),
        isAlarmEnabled: true,
      );

      TaskAlarmService.instance.triggerAlarm(task);

      expect(TaskAlarmService.instance.isRinging, isTrue);
      expect(TaskAlarmService.instance.activeAlarmTask?.id, 'alarm-test-1');

      // Snooze for 5 minutes
      TaskAlarmService.instance.snooze(task, minutes: 5);
      expect(TaskAlarmService.instance.isRinging, isFalse);

      // Re-trigger and Dismiss
      TaskAlarmService.instance.triggerAlarm(task);
      expect(TaskAlarmService.instance.isRinging, isTrue);

      await TaskAlarmService.instance.dismiss(task);
      expect(TaskAlarmService.instance.isRinging, isFalse);
    });

    test('startTaskNow updates status to On going and silences alarm',
        () async {
      final task = Task(
        id: 'start-task-test',
        title: 'Build UI prototype',
        dueDate: DateTime.now(),
        dueTime: '02:00 pm',
        createdAt: DateTime.now(),
        isAlarmEnabled: true,
        status: 'In Process',
      );

      TaskAlarmService.instance.triggerAlarm(task);
      expect(TaskAlarmService.instance.isRinging, isTrue);

      Task? updatedTask;
      await TaskAlarmService.instance.startTaskNow(
        task,
        onUpdateTask: (u) {
          updatedTask = u;
        },
      );

      expect(TaskAlarmService.instance.isRinging, isFalse);
      expect(updatedTask, isNotNull);
      expect(updatedTask!.status, 'On going');
      expect(updatedTask!.isAlarmEnabled, isFalse);
    });
  });

  group('TaskAlarmRingingDialog Widget Tests', () {
    testWidgets(
        'TaskAlarmRingingDialog renders task info and buttons accurately',
        (WidgetTester tester) async {
      final task = Task(
        id: 'modal-test-task',
        title: 'Review Product Architecture',
        subtitle: 'Digital Product Design',
        description: 'Sync with frontend lead on state management.',
        category: 'Development',
        priority: TaskPriority.urgent,
        dueDate: DateTime.now(),
        dueTime: '10:00 AM',
        createdAt: DateTime.now(),
        isAlarmEnabled: true,
      );

      bool startWorkingCalled = false;
      Task? updatedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    TaskAlarmRingingDialog.show(
                      ctx,
                      task: task,
                      onTaskUpdated: (u) => updatedTask = u,
                      onStartWorking: () => startWorkingCalled = true,
                    );
                  },
                  child: const Text('Open Alarm Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Alarm Modal'));
      await tester.pumpAndSettle();

      // 1. Verify header badge
      expect(find.text('ALARM RINGING'), findsOneWidget);
      expect(find.text('Time to Start Task! ⏰'), findsOneWidget);

      // 2. Verify task title & details
      expect(find.text('Review Product Architecture'), findsOneWidget);
      expect(find.text('Development'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);

      // 3. Verify action buttons exist
      expect(find.text('Start Task Now 🚀'), findsOneWidget);
      expect(find.text('Snooze (5m)'), findsOneWidget);
      expect(find.text('Dismiss ✕'), findsOneWidget);

      // 4. Tap "Start Task Now 🚀"
      await tester.tap(find.text('Start Task Now 🚀'));
      await tester.pumpAndSettle();

      expect(startWorkingCalled, isTrue);
      expect(updatedTask, isNotNull);
      expect(updatedTask!.status, 'On going');
    });
  });

  group('ActiveAlarmsScreen Widget Tests', () {
    testWidgets('ActiveAlarmsScreen shows hero test button and handles test tap',
        (WidgetTester tester) async {
      final repo = _FakeTaskRepo();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TaskBloc>(
            create: (_) => TaskBloc(
              taskRepository: repo,
              userId: 'test_user',
            ),
            child: const ActiveAlarmsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title and hero test card
      expect(find.text('Task Start Alarms'), findsOneWidget);
      expect(find.text('In-App Alarm Engine'), findsOneWidget);
      expect(find.text('Test Start Alarm Now 🔔'), findsOneWidget);

      // Tap test button
      await tester.tap(find.text('Test Start Alarm Now 🔔'));
      await tester.pump();

      // Alarm should now be ringing
      expect(TaskAlarmService.instance.isRinging, isTrue);

      TaskAlarmService.instance.stop();
      await tester.pump();
    });
  });

  group('Notification Action Responses', () {
    test('handleNotificationResponse dismisses alarm', () async {
      final task = Task(
        id: 'notif-task-1',
        title: 'Notification Test Task',
        isAlarmEnabled: true,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      TaskAlarmService.instance.syncTasks([task]);
      TaskAlarmService.instance.triggerAlarm(task);

      expect(TaskAlarmService.instance.isRinging, isTrue);

      await MobileNotificationService.instance.handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'dismiss',
          payload: 'notif-task-1',
        ),
      );

      expect(TaskAlarmService.instance.isRinging, isFalse);
    });

    test('handleNotificationResponse snoozes alarm for 5 minutes', () async {
      final task = Task(
        id: 'notif-task-2',
        title: 'Notification Snooze Task',
        isAlarmEnabled: true,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      TaskAlarmService.instance.syncTasks([task]);
      TaskAlarmService.instance.triggerAlarm(task);

      expect(TaskAlarmService.instance.isRinging, isTrue);

      await MobileNotificationService.instance.handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'snooze_5m',
          payload: 'notif-task-2',
        ),
      );

      expect(TaskAlarmService.instance.isRinging, isFalse);
    });

    test('handleNotificationResponse starts task and triggers callback',
        () async {
      final task = Task(
        id: 'notif-task-3',
        title: 'Notification Start Task',
        isAlarmEnabled: true,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      Task? updatedFromCallback;
      TaskAlarmService.instance.onTaskUpdatedCallback = (t) {
        updatedFromCallback = t;
      };

      TaskAlarmService.instance.syncTasks([task]);
      TaskAlarmService.instance.triggerAlarm(task);

      expect(TaskAlarmService.instance.isRinging, isTrue);

      await MobileNotificationService.instance.handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'start_now',
          payload: 'notif-task-3',
        ),
      );

      expect(TaskAlarmService.instance.isRinging, isFalse);
      expect(updatedFromCallback, isNotNull);
      expect(updatedFromCallback!.status, 'On going');
    });

    test(
        'handleNotificationResponse opens alarm when notification body is tapped',
        () async {
      final task = Task(
        id: 'notif-task-4',
        title: 'Notification Body Tap Task',
        isAlarmEnabled: true,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      TaskAlarmService.instance.syncTasks([task]);
      TaskAlarmService.instance.stop();

      expect(TaskAlarmService.instance.isRinging, isFalse);

      await MobileNotificationService.instance.handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: 'notif-task-4',
        ),
      );

      expect(TaskAlarmService.instance.isRinging, isTrue);
      expect(TaskAlarmService.instance.activeAlarmTask?.id, 'notif-task-4');
    });
  });
}
