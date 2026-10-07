import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';
import 'task_event.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<Task> allTasks;
  final List<Task> filteredTasks;
  final TaskFilter activeFilter;
  final String? selectedCategory;
  final String searchQuery;
  final int todayCompletedCount;
  final int todayPendingCount;
  final int todayTotalCount;
  final double todayProgress;
  final int urgentCount;
  final int streakDays;
  final bool isCloudSync;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.activeFilter = TaskFilter.all,
    this.selectedCategory,
    this.searchQuery = '',
    required this.todayCompletedCount,
    required this.todayPendingCount,
    required this.todayTotalCount,
    required this.todayProgress,
    required this.urgentCount,
    this.streakDays = 5,
    this.isCloudSync = false,
  });

  TaskLoaded copyWith({
    List<Task>? allTasks,
    List<Task>? filteredTasks,
    TaskFilter? activeFilter,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    int? todayCompletedCount,
    int? todayPendingCount,
    int? todayTotalCount,
    double? todayProgress,
    int? urgentCount,
    int? streakDays,
    bool? isCloudSync,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      todayCompletedCount: todayCompletedCount ?? this.todayCompletedCount,
      todayPendingCount: todayPendingCount ?? this.todayPendingCount,
      todayTotalCount: todayTotalCount ?? this.todayTotalCount,
      todayProgress: todayProgress ?? this.todayProgress,
      urgentCount: urgentCount ?? this.urgentCount,
      streakDays: streakDays ?? this.streakDays,
      isCloudSync: isCloudSync ?? this.isCloudSync,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        activeFilter,
        selectedCategory,
        searchQuery,
        todayCompletedCount,
        todayPendingCount,
        todayTotalCount,
        todayProgress,
        urgentCount,
        streakDays,
        isCloudSync,
      ];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
