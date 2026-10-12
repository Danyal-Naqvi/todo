import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/firebase/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/data/datasources/task_remote_datasource.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/bloc/task_event.dart';
import 'core/services/task_alarm_host.dart';
import 'core/services/task_alarm_service.dart';
import 'features/tasks/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Firebase (safely handles missing credentials with offline fallback)
  final isFirebaseReady = await FirebaseService.instance.initialize();

  // Initialize In-App Alarm Manager
  await TaskAlarmService.instance.initialize();

  // Setup datasources and repository
  final localDataSource = SharedPreferencesTaskLocalDataSource();
  final remoteDataSource =
      isFirebaseReady ? FirebaseTaskRemoteDataSource() : null;

  final taskRepository = TaskRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );

  final activeUserId = FirebaseService.instance.activeUserId;

  runApp(
    TaskFlowApp(
      taskRepository: taskRepository,
      userId: activeUserId,
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  final TaskRepository? taskRepository;
  final ThemeCubit? themeCubit;
  final ProfileCubit? profileCubit;
  final String? userId;

  const TaskFlowApp({
    super.key,
    this.taskRepository,
    this.themeCubit,
    this.profileCubit,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final repo = taskRepository ??
        TaskRepositoryImpl(
          localDataSource: SharedPreferencesTaskLocalDataSource(),
        );
    final activeId = userId ?? 'guest_user';

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => themeCubit ?? ThemeCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => profileCubit ?? ProfileCubit(),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            taskRepository: repo,
            userId: activeId,
          )..add(const LoadTasks()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const TaskAlarmHost(
              child: HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}

