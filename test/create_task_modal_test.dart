import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/presentation/widgets/create_task_modal.dart';

void main() {
  testWidgets('CreateTaskModal removes all crossed functionalities',
      (WidgetTester tester) async {
    Task? createdTask;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateTaskModal(
            onTaskCreated: (task) {
              createdTask = task;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Top Search button is REMOVED
    expect(find.byIcon(Icons.search), findsNothing);

    // 2. Verify Assignee field is REMOVED
    expect(find.text('| Assignee'), findsNothing);

    // 3. Verify Formatting tools bar is REMOVED
    expect(find.byIcon(Icons.attach_file_rounded), findsNothing);
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);

    // 4. Verify Subtasks input row in modal is REMOVED
    expect(find.text('Add a subtask...'), findsNothing);

    // 5. Verify "Get alert for this task" toggle is REMOVED
    expect(find.text('Get alert for this task'), findsNothing);
    expect(find.byType(Switch), findsNothing);

    // 6. Verify required fields ARE present
    expect(find.text('New Tasks'), findsOneWidget);
    expect(find.text('| Task Title'), findsOneWidget);
    expect(find.text('Objective'), findsOneWidget);
    expect(find.text('Add objective'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);

    // 7. Verify creating a task with title and objective works
    await tester.enterText(find.widgetWithText(TextField, '| Task Title'), 'Design Sprint');
    await tester.enterText(find.widgetWithText(TextField, 'Add objective'), 'Complete interactive prototypes');

    await tester.ensureVisible(find.text('Create Task'));
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(createdTask, isNotNull);
    expect(createdTask!.title, 'Design Sprint');
    expect(createdTask!.description, 'Complete interactive prototypes');
  });

  testWidgets(
      'CreateTaskModal allows selecting time with AM/PM and updates dueTime and dueDate',
      (WidgetTester tester) async {
    Task? createdTask;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateTaskModal(
            onTaskCreated: (task) {
              createdTask = task;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify time icon is present
    expect(find.byIcon(Icons.access_time_filled_rounded), findsOneWidget);

    // Verify quick preset chips exist
    expect(find.text('09:00 AM'), findsOneWidget);
    expect(find.text('02:00 PM'), findsOneWidget);

    // Select 02:00 PM (14:00)
    await tester.tap(find.text('02:00 PM'));
    await tester.pumpAndSettle();

    // Enter title
    await tester.enterText(
        find.widgetWithText(TextField, '| Task Title'), 'Afternoon Sync');

    await tester.ensureVisible(find.text('Create Task'));
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(createdTask, isNotNull);
    expect(createdTask!.title, 'Afternoon Sync');
    expect(createdTask!.dueTime, '02:00 PM');
    expect(createdTask!.dueDate!.hour, 14);
    expect(createdTask!.dueDate!.minute, 0);
  });
}

