import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/features/tasks/domain/entities/subtask.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_event.dart';
import 'package:todoapp/features/tasks/presentation/screens/schedule_screen.dart';

class _FakeTaskRepo implements TaskRepository {
  List<Task> tasks;
  _FakeTaskRepo(this.tasks);

  @override
  bool get isCloudSyncEnabled => false;
  @override
  Stream<List<Task>> watchTasks({required String userId}) => Stream.value(tasks);
  @override
  Future<List<Task>> getTasks({required String userId}) async => tasks;
  @override
  Future<void> addTask(Task task, {required String userId}) async {
    tasks.add(task);
  }
  @override
  Future<void> updateTask(Task task, {required String userId}) async {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) tasks[idx] = task;
  }
  @override
  Future<void> deleteTask(String taskId, {required String userId}) async {
    tasks.removeWhere((t) => t.id == taskId);
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
  testWidgets('ScheduleScreen shows dynamic real dates and real tasks for today',
      (WidgetTester tester) async {
    final today = DateTime.now();

    final testTasks = [
      Task(
        id: 'task-today-1',
        title: 'Real Morning Standup',
        dueDate: today,
        dueTime: '09:00 am',
        timeRange: '09.00 am - 10.15 am',
        status: 'In Process',
        createdAt: today,
        subtasks: const [
          SubTask(id: 'st-1', title: 'Share updates', isCompleted: true),
        ],
      ),
      Task(
        id: 'task-today-2',
        title: 'Client Demo Review',
        dueDate: today,
        dueTime: '11:00 am',
        timeRange: '11.00 am - 12.00 pm',
        status: 'On going',
        createdAt: today,
      ),
    ];

    final repo = _FakeTaskRepo(testTasks);
    final bloc = TaskBloc(taskRepository: repo, userId: 'test_user')
      ..add(const LoadTasks());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: bloc,
          child: const ScheduleScreen(),
        ),
      ),
    );

    // Initial state pump
    await tester.pumpAndSettle();

    // Verify header has today's real date, NOT hardcoded 17 January 2024
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(today);
    expect(find.text(todayFormatted), findsOneWidget);
    expect(find.text('Wednesday, 17 January 2024'), findsNothing);

    // Verify tasks due today appear in timeline
    expect(find.text('Real Morning Standup'), findsOneWidget);
    expect(find.text('Client Demo Review'), findsOneWidget);

    // Verify dummy mockup text is GONE
    expect(find.text('Optimize server response time.'), findsNothing);
    expect(find.text('Team Meeting\n(Designer and Developer)'), findsNothing);
    expect(find.text('Optimization Website for Rune.io'), findsNothing);

    // Test filter chips
    await tester.tap(find.text('On going').first);
    await tester.pumpAndSettle();

    // Now only On going task should be visible in timeline
    expect(find.text('Client Demo Review'), findsOneWidget);
    expect(find.text('Real Morning Standup'), findsNothing);

    // Switch filter back to All
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Real Morning Standup'), findsOneWidget);
    expect(find.text('Client Demo Review'), findsOneWidget);
  });

  testWidgets('ScheduleScreen back button invokes onBackToHome callback',
      (WidgetTester tester) async {
    bool backCalled = false;
    final repo = _FakeTaskRepo([]);
    final bloc = TaskBloc(taskRepository: repo, userId: 'test_user')
      ..add(const LoadTasks());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: bloc,
          child: ScheduleScreen(
            onBackToHome: () {
              backCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(backCalled, isTrue);
  });

  testWidgets(
      'ScheduleScreen maps AM and PM tasks to their proper hourly timeline slots',
      (WidgetTester tester) async {
    final today = DateTime.now();

    final testTasks = [
      Task(
        id: 'am-task',
        title: 'Morning Breakfast Meeting',
        dueDate: today,
        dueTime: '09:00 AM',
        status: 'In Process',
        createdAt: today,
      ),
      Task(
        id: 'noon-task',
        title: 'Lunch and Learn',
        dueDate: today,
        dueTime: '12:00 PM',
        status: 'In Process',
        createdAt: today,
      ),
      Task(
        id: 'pm-task',
        title: 'Afternoon Architecture Review',
        dueDate: today,
        dueTime: '02:30 PM',
        status: 'In Process',
        createdAt: today,
      ),
    ];

    final repo = _FakeTaskRepo(testTasks);
    final bloc = TaskBloc(taskRepository: repo, userId: 'test_user')
      ..add(const LoadTasks());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: bloc,
          child: const ScheduleScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 3 tasks are present
    expect(find.text('Morning Breakfast Meeting'), findsOneWidget);
    expect(find.text('Lunch and Learn'), findsOneWidget);
    expect(find.text('Afternoon Architecture Review'), findsOneWidget);

    // Verify timeline slot labels exist
    expect(find.text('09 am'), findsOneWidget);
    expect(find.text('12 pm'), findsOneWidget);
    expect(find.text('02 pm'), findsOneWidget);

    // Verify circled avatars and arrow icon are REMOVED from task cards
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);

    // Verify prominent status badges with their icons exist
    expect(find.byIcon(Icons.timelapse_rounded), findsNWidgets(3));
  });
}



