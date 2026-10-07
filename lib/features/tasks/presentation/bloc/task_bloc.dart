import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final String _userId;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TaskBloc({
    required this._taskRepository,
    required this._userId,
  })  : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<TasksUpdated>(_onTasksUpdated);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<ToggleSubTaskStatus>(_onToggleSubTaskStatus);
    on<TogglePinTask>(_onTogglePinTask);
    on<SetFilter>(_onSetFilter);
    on<SetCategory>(_onSetCategory);
    on<SearchTasks>(_onSearchTasks);
    on<ClearCompletedTasks>(_onClearCompletedTasks);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(const TaskLoading());
    _tasksSubscription?.cancel();
    _tasksSubscription = _taskRepository
        .watchTasks(userId: _userId)
        .listen((tasks) => add(TasksUpdated(tasks)));
  }

  void _onTasksUpdated(TasksUpdated event, Emitter<TaskState> emit) {
    final allTasks = event.tasks;

    final currentFilter = state is TaskLoaded
        ? (state as TaskLoaded).activeFilter
        : TaskFilter.all;
    final currentCategory = state is TaskLoaded
        ? (state as TaskLoaded).selectedCategory
        : null;
    final currentSearch = state is TaskLoaded
        ? (state as TaskLoaded).searchQuery
        : '';

    final filtered = _applyFilters(
      allTasks: allTasks,
      filter: currentFilter,
      category: currentCategory,
      query: currentSearch,
    );

    // Calculate today stats
    final now = DateTime.now();
    final todayTasks = allTasks.where((t) {
      if (t.dueDate != null) {
        return t.dueDate!.year == now.year &&
            t.dueDate!.month == now.month &&
            t.dueDate!.day == now.day;
      }
      return t.createdAt.year == now.year &&
          t.createdAt.month == now.month &&
          t.createdAt.day == now.day;
    }).toList();

    final todayCompleted = todayTasks.where((t) => t.isCompleted).length;
    final todayPending = todayTasks.length - todayCompleted;
    final todayProgress =
        todayTasks.isEmpty ? 0.0 : (todayCompleted / todayTasks.length);
    final urgentCount = allTasks
        .where((t) => !t.isCompleted && t.priority == TaskPriority.urgent)
        .length;

    emit(TaskLoaded(
      allTasks: allTasks,
      filteredTasks: filtered,
      activeFilter: currentFilter,
      selectedCategory: currentCategory,
      searchQuery: currentSearch,
      todayCompletedCount: todayCompleted,
      todayPendingCount: todayPending,
      todayTotalCount: todayTasks.length,
      todayProgress: todayProgress,
      urgentCount: urgentCount,
      streakDays: 7,
      isCloudSync: _taskRepository.isCloudSyncEnabled,
    ));
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.addTask(event.task, userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task, userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId, userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  Future<void> _onToggleTaskStatus(
      ToggleTaskStatus event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.toggleTaskStatus(event.taskId, userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to toggle task: $e'));
    }
  }

  Future<void> _onToggleSubTaskStatus(
      ToggleSubTaskStatus event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.toggleSubTaskStatus(
        event.taskId,
        event.subTaskId,
        userId: _userId,
      );
    } catch (e) {
      emit(TaskError('Failed to toggle subtask: $e'));
    }
  }

  Future<void> _onTogglePinTask(
      TogglePinTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.togglePinTask(event.taskId, userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to pin task: $e'));
    }
  }

  void _onSetFilter(SetFilter event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final s = state as TaskLoaded;
      final filtered = _applyFilters(
        allTasks: s.allTasks,
        filter: event.filter,
        category: s.selectedCategory,
        query: s.searchQuery,
      );
      emit(s.copyWith(
        activeFilter: event.filter,
        filteredTasks: filtered,
      ));
    }
  }

  void _onSetCategory(SetCategory event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final s = state as TaskLoaded;
      final filtered = _applyFilters(
        allTasks: s.allTasks,
        filter: s.activeFilter,
        category: event.category,
        query: s.searchQuery,
      );
      emit(s.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
        filteredTasks: filtered,
      ));
    }
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final s = state as TaskLoaded;
      final filtered = _applyFilters(
        allTasks: s.allTasks,
        filter: s.activeFilter,
        category: s.selectedCategory,
        query: event.query,
      );
      emit(s.copyWith(
        searchQuery: event.query,
        filteredTasks: filtered,
      ));
    }
  }

  Future<void> _onClearCompletedTasks(
      ClearCompletedTasks event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.clearCompletedTasks(userId: _userId);
    } catch (e) {
      emit(TaskError('Failed to clear completed tasks: $e'));
    }
  }

  List<Task> _applyFilters({
    required List<Task> allTasks,
    required TaskFilter filter,
    required String? category,
    required String query,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var list = allTasks.where((t) {
      // 1. Text Search query
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(q);
        final matchesDesc = t.description.toLowerCase().contains(q);
        final matchesTag = t.tags.any((tag) => tag.toLowerCase().contains(q));
        if (!matchesTitle && !matchesDesc && !matchesTag) {
          return false;
        }
      }

      // 2. Category filter
      if (category != null && category.isNotEmpty) {
        if (t.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // 3. Tab filter
      switch (filter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.today:
          if (t.dueDate != null) {
            final d =
                DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return d.isAtSameMomentAs(today);
          }
          return false;
        case TaskFilter.upcoming:
          if (t.dueDate != null) {
            final d =
                DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
            return d.isAfter(today) && !t.isCompleted;
          }
          return false;
        case TaskFilter.urgent:
          return t.priority == TaskPriority.urgent && !t.isCompleted;
        case TaskFilter.completed:
          return t.isCompleted;
      }
    }).toList();

    // Sort: Pinned first, then by priority weight, then by dueDate, then createdAt
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.weight.compareTo(a.priority.weight);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
