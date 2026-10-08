import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:todoapp/features/tasks/domain/entities/task.dart';
import 'package:todoapp/features/tasks/domain/repositories/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:todoapp/features/tasks/presentation/bloc/task_event.dart';
import 'package:todoapp/features/tasks/presentation/screens/home_screen.dart';

class _FakeTaskRepo implements TaskRepository {
  List<Task> tasks = [];
  _FakeTaskRepo();

  @override
  bool get isCloudSyncEnabled => false;
  @override
  Stream<List<Task>> watchTasks({required String userId}) => Stream.value(tasks);
  @override
  Future<List<Task>> getTasks({required String userId}) async => tasks;
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'HomeScreen provides a global dark/light mode toggle button that switches theme',
      (WidgetTester tester) async {
    final themeCubit = ThemeCubit();
    final fakeRepo = _FakeTaskRepo();
    final taskBloc = TaskBloc(taskRepository: fakeRepo, userId: 'test_user')
      ..add(const LoadTasks());
    final profileCubit = ProfileCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>.value(value: themeCubit),
          BlocProvider<TaskBloc>.value(value: taskBloc),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return MaterialApp(
              themeMode: mode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Theme toggle button is rendered
    final toggleBtn = find.byKey(const ValueKey('home_theme_toggle_btn'));
    expect(toggleBtn, findsOneWidget);

    // Initial state: Light mode -> dark mode icon is shown
    expect(themeCubit.state, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_rounded), findsNothing);

    // Tap the toggle button to switch to Dark mode
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    // Verify theme changed to Dark mode
    expect(themeCubit.state, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsNothing);

    // Tap again to switch back to Light mode
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    // Verify theme changed back to Light mode
    expect(themeCubit.state, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_rounded), findsNothing);
  });
}
