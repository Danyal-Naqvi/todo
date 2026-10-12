import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/features/tasks/domain/entities/subtask.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/screens/project_detail_screen.dart';

class _FakeTaskRepo implements TaskRepository {
  @override
  bool get isCloudSyncEnabled => false;
  @override
  Stream<List<Task>> watchTasks({required String userId}) => Stream.value([]);
  @override
  Future<List<Task>> getTasks({required String userId}) async => [];
  @override
  Future<void> addTask(Task task, {required String userId}) async {}
  @override
  Future<void> updateTask(Task task, {required String userId}) async {}
  @override
  Future<void> deleteTask(String taskId, {required String userId}) async {}
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
  testWidgets(
      'ProjectDetailScreen reflects real objective, removes crossed items, and manages subtasks',
      (WidgetTester tester) async {
    final testTask = Task(
      id: 'him-task',
      title: 'him',
      description: 'Build user authentication and profile synchronization.',
      dueDate: DateTime(2026, 10, 15),
      createdAt: DateTime.now(),
      subtasks: const [
        SubTask(id: 'st-1', title: 'Implement OAuth', isCompleted: false),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: _FakeTaskRepo(),
            userId: 'test_user',
          ),
          child: ProjectDetailScreen(task: testTask),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify crossed out items are REMOVED:
    // Calendar icon button is gone
    expect(find.byIcon(Icons.calendar_month_outlined), findsNothing);
    // Team section is gone
    expect(find.text('Team'), findsNothing);

    // 2. Verify Top Circle: Objective is real and NOT dummy Rune.io text
    expect(
      find.text('Build user authentication and profile synchronization.'),
      findsOneWidget,
    );
    expect(find.textContaining('Rune.io job finder website'), findsNothing);

    // 3. Verify Bottom Circle: Header is Subtasks, NOT Today's Tasks
    expect(find.text("Today's Tasks"), findsNothing);
    expect(find.textContaining('Subtasks'), findsOneWidget);

    // 4. Verify no dummy fallback subtasks are injected
    expect(find.text('Job Matching Optimization'), findsNothing);
    expect(find.text('Employer Dashboard Upgrades'), findsNothing);
    expect(find.text('Continuous Feedback Loop'), findsNothing);

    // 5. Verify actual subtask is present
    expect(find.text('Implement OAuth'), findsOneWidget);

    // 6. Test adding a subtask
    await tester.tap(find.text('Add Subtask'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField), 'Test cloud storage integration');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Test cloud storage integration'), findsOneWidget);
  });

  testWidgets(
      'ProjectDetailScreen 3-dots popup menu cancels task and migrates status',
      (WidgetTester tester) async {
    final repo = _FakeTaskRepo();

    final testTask = Task(
      id: 'wish-task',
      title: 'wish',
      description: 'me',
      status: 'In Process',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: repo,
            userId: 'test_user',
          ),
          child: ProjectDetailScreen(task: testTask),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial status badge
    expect(find.text('In Process'), findsOneWidget);

    // Tap 3-dots button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify popup options exist
    expect(find.text('Cancel Task'), findsOneWidget);
    expect(find.text('Mark as On going'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsOneWidget);

    // Tap "Cancel Task"
    await tester.tap(find.text('Cancel Task'));
    await tester.pumpAndSettle();

    // Verify status changed to Canceled
    expect(find.text('Canceled'), findsOneWidget);
  });

  testWidgets(
      'ProjectDetailScreen does NOT show Cancel Task option for Completed tasks',
      (WidgetTester tester) async {
    final repo = _FakeTaskRepo();

    final completedTask = Task(
      id: 'completed-task-1',
      title: 'Completed Project',
      description: 'Finished all objectives.',
      status: 'Completed',
      isCompleted: true,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: repo,
            userId: 'test_user',
          ),
          child: ProjectDetailScreen(task: completedTask),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial status badge shows Completed
    expect(find.text('Completed'), findsOneWidget);

    // Tap 3-dots button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Verify "Cancel Task" is NOT present for completed tasks
    expect(find.text('Cancel Task'), findsNothing);
    // Verify "Mark as Completed" is also NOT present (already completed)
    expect(find.text('Mark as Completed'), findsNothing);

    // Verify reopening / migration options are present
    expect(find.text('Mark as On going'), findsOneWidget);
    expect(find.text('Mark as In Process'), findsOneWidget);
    expect(find.text('Delete Task'), findsOneWidget);
  });
}

