import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_event.dart';
import 'package:todoapp/features/tasks/presentation/screens/focus_timer_screen.dart';

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
  testWidgets('FocusTimerScreen displays timer, switches modes, and links to tasks',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final sampleTasks = [
      Task(
        id: 'timer-task-1',
        title: 'Review Physics Assignment',
        dueDate: now,
        status: 'In Process',
        createdAt: now,
      ),
      Task(
        id: 'timer-task-2',
        title: 'Grocery Shopping list',
        dueDate: now,
        status: 'Pending',
        createdAt: now,
      ),
    ];

    final fakeRepo = _FakeTaskRepo(sampleTasks);
    final taskBloc = TaskBloc(taskRepository: fakeRepo, userId: 'test_user');
    taskBloc.add(const LoadTasks());

    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: taskBloc,
          child: FocusTimerScreen(
            onBackToHome: () {
              backPressed = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Focus Timer elements
    expect(find.text('Focus & Timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Review Physics Assignment'), findsOneWidget);

    // Verify Mode Selector buttons
    expect(find.text('Pomodoro (25m)'), findsOneWidget);
    expect(find.text('Short Break (5m)'), findsOneWidget);
    expect(find.text('Long (15m)'), findsOneWidget);

    // Switch to Short Break (5 min)
    await tester.tap(find.text('Short Break (5m)'));
    await tester.pumpAndSettle();
    expect(find.text('05:00'), findsOneWidget);

    // Switch to Long Break (15 min)
    await tester.tap(find.text('Long (15m)'));
    await tester.pumpAndSettle();
    expect(find.text('15:00'), findsOneWidget);

    // Switch back to Pomodoro (25 min)
    await tester.tap(find.text('Pomodoro (25m)'));
    await tester.pumpAndSettle();
    expect(find.text('25:00'), findsOneWidget);

    // Tap +5 min button
    await tester.tap(find.text('+5 min'));
    await tester.pumpAndSettle();
    expect(find.text('30:00'), findsOneWidget);

    // Test back button
    final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();
    expect(backPressed, isTrue);

    // Verify Today Productivity Goal section
    expect(find.text("Today's Productivity Goal"), findsOneWidget);
    expect(find.text('Focus Time'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Breaks'), findsOneWidget);
  });
}
