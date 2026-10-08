import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/features/profile/domain/entities/user_profile.dart';
import 'package:todoapp/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_event.dart';
import 'package:todoapp/features/tasks/presentation/screens/edit_profile_screen.dart';
import 'package:todoapp/features/tasks/presentation/screens/profile_screen.dart';
import 'package:todoapp/features/tasks/presentation/widgets/user_avatar_widget.dart';

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
  Future<void> clearCompletedTasks({required String userId}) async {
    tasks.removeWhere((t) => t.isCompleted || t.status.toLowerCase() == 'completed');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'ProfileScreen removes 5 unwanted bars, shows real task stats, and allows editing profile',
      (WidgetTester tester) async {
    final now = DateTime.now();
    final sampleTasks = [
      Task(
        id: 'p-task-1',
        title: 'Task 1 in process',
        dueDate: now,
        status: 'In Process',
        createdAt: now,
      ),
      Task(
        id: 'p-task-2',
        title: 'Task 2 in process',
        dueDate: now,
        status: 'In Process',
        createdAt: now,
      ),
      Task(
        id: 'p-task-3',
        title: 'Task 3 completed',
        dueDate: now,
        isCompleted: true,
        status: 'Completed',
        createdAt: now,
      ),
    ];

    final fakeRepo = _FakeTaskRepo(sampleTasks);
    final taskBloc = TaskBloc(taskRepository: fakeRepo, userId: 'test_user')
      ..add(const LoadTasks());
    final profileCubit = ProfileCubit(
      initialProfile: const UserProfile(
        name: 'Bruce Wayne',
        role: 'Product Designer',
        bio: 'Focus on what matters',
        email: 'bruce@wayne.com',
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TaskBloc>.value(value: taskBloc),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify 5 unwanted bars are completely GONE
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Security'), findsNothing);
    expect(find.text('Language & Region'), findsNothing);
    expect(find.text('Go Premium'), findsNothing);
    expect(find.text('Help Center'), findsNothing);

    // 2. Verify real dynamic stats: 2 In Process tasks, 1 Completed task
    expect(find.text('2'), findsOneWidget); // 2 In Process
    expect(find.text('In Process tasks'), findsOneWidget);
    expect(find.text('1'), findsWidgets); // 1 Completed
    expect(find.text('Completed tasks'), findsOneWidget);

    // 3. Verify user profile details
    expect(find.text('Bruce Wayne'), findsOneWidget);
    expect(find.text('Product Designer'), findsWidgets);
    expect(find.text('"Focus on what matters"'), findsOneWidget);

    // 4. Tap Edit Profile button
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    // Verify EditProfileScreen opened (NOT AuthScreen / Create Account)
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);
    expect(find.text('Sign Up'), findsNothing);
    expect(find.text('Log In'), findsNothing);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Choose Your Avatar'), findsOneWidget);

    // 5. Change name and role
    final nameField = find.widgetWithText(TextField, 'Bruce Wayne');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Clark Kent');

    final roleField = find.widgetWithText(TextField, 'Product Designer');
    expect(roleField, findsOneWidget);
    await tester.enterText(roleField, 'Journalist');

    // Tap Save Changes (top bar check button)
    await tester.tap(find.byKey(const ValueKey('edit_profile_save_btn')));
    await tester.pumpAndSettle();

    // 6. Verify Gallery Photo button is present on ProfileScreen
    expect(find.text('Gallery Photo'), findsOneWidget);

    // 7. Tap avatar to open bottom sheet options
    await tester.tap(find.byType(UserAvatarWidget));
    await tester.pumpAndSettle();

    // Verify modal sheet appears with "Upload from Phone Gallery"
    expect(find.text('Profile Photo'), findsOneWidget);
    expect(find.text('Upload from Phone Gallery'), findsOneWidget);
    expect(find.text('Edit Profile Information'), findsOneWidget);
  });

  testWidgets('ProfileScreen and EditProfileScreen render in Dark Mode with dark theme styles',
      (WidgetTester tester) async {
    final fakeRepo = _FakeTaskRepo([]);
    final taskBloc = TaskBloc(taskRepository: fakeRepo, userId: 'test_user')
      ..add(const LoadTasks());
    final profileCubit = ProfileCubit(
      initialProfile: const UserProfile(
        name: 'Dark Knight',
        role: 'Hero',
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TaskBloc>.value(value: taskBloc),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dark Knight'), findsOneWidget);
    expect(find.text('Gallery Photo'), findsOneWidget);

    // Open EditProfileScreen in dark mode
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Upload from Phone Gallery'), findsOneWidget);
  });
}
