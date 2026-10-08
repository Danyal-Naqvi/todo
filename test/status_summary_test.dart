import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_event.dart';
import 'package:todoapp/features/tasks/presentation/screens/home_screen.dart';
import 'package:todoapp/features/tasks/presentation/widgets/status_summary_grid.dart';

class _FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;
  _FakeTaskRepository(this._tasks);

  @override
  bool get isCloudSyncEnabled => false;

  @override
  Stream<List<Task>> watchTasks({required String userId}) =>
      Stream.value(_tasks);

  @override
  Future<List<Task>> getTasks({required String userId}) async => _tasks;

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
      'StatusSummaryGrid shows real task numbers without dummy fallbacks',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusSummaryGrid(
            ongoingCount: 0,
            inProcessCount: 5,
            completedCount: 1,
            canceledCount: 2,
          ),
        ),
      ),
    );

    // Verify real counts are displayed
    expect(find.text('0 Tasks'), findsOneWidget); // On going
    expect(find.text('5 Tasks'), findsOneWidget); // In Process
    expect(find.text('1 Task'), findsOneWidget); // Completed (singular)
    expect(find.text('2 Tasks'), findsOneWidget); // Canceled

    // Ensure dummy numbers from earlier mockups are NOT present
    expect(find.text('24 Tasks'), findsNothing);
    expect(find.text('12 Tasks'), findsNothing);
    expect(find.text('42 Tasks'), findsNothing);
    expect(find.text('8 Tasks'), findsNothing);
  });

  testWidgets(
      'HomeScreen calculates real counts dynamically from loaded tasks',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final testTasks = [
      Task(
        id: '1',
        title: 'Task 1 Ongoing',
        status: 'On going',
        createdAt: now,
      ),
      Task(
        id: '2',
        title: 'Task 2 In Process',
        status: 'In Process',
        createdAt: now,
      ),
      Task(
        id: '3',
        title: 'Task 3 In Process',
        status: 'In Process',
        createdAt: now,
      ),
      Task(
        id: '4',
        title: 'Task 4 Completed',
        status: 'Completed',
        isCompleted: true,
        createdAt: now,
      ),
      Task(
        id: '5',
        title: 'Task 5 Canceled',
        status: 'Canceled',
        createdAt: now,
      ),
    ];

    final fakeRepo = _FakeTaskRepository(testTasks);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: fakeRepo,
            userId: 'test_user',
          )..add(const LoadTasks()),
          child: const HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify exact real counts inside StatusSummaryGrid
    final gridFinder = find.byType(StatusSummaryGrid);
    expect(
      find.descendant(of: gridFinder, matching: find.text('1 Task')),
      findsNWidgets(3), // 1 Ongoing, 1 Completed, 1 Canceled
    );
    expect(
      find.descendant(of: gridFinder, matching: find.text('2 Tasks')),
      findsOneWidget, // 2 In Process
    );

    // Ensure dummy numbers are NOT displayed anywhere
    expect(find.text('24 Tasks'), findsNothing);
    expect(find.text('12 Tasks'), findsNothing);
    expect(find.text('42 Tasks'), findsNothing);
    expect(find.text('8 Tasks'), findsNothing);
  });
}
