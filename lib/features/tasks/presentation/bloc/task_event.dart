import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

enum TaskFilter {
  all(label: 'All Tasks'),
  today(label: 'Today'),
  upcoming(label: 'Upcoming'),
  urgent(label: 'Urgent 🔥'),
  completed(label: 'Completed ✓');

  final String label;
  const TaskFilter({required this.label});
}

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class TasksUpdated extends TaskEvent {
  final List<Task> tasks;
  const TasksUpdated(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskStatus extends TaskEvent {
  final String taskId;
  const ToggleTaskStatus(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleSubTaskStatus extends TaskEvent {
  final String taskId;
  final String subTaskId;
  const ToggleSubTaskStatus(this.taskId, this.subTaskId);

  @override
  List<Object?> get props => [taskId, subTaskId];
}

class TogglePinTask extends TaskEvent {
  final String taskId;
  const TogglePinTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class SetFilter extends TaskEvent {
  final TaskFilter filter;
  const SetFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SetCategory extends TaskEvent {
  final String? category;
  const SetCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchTasks extends TaskEvent {
  final String query;
  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearCompletedTasks extends TaskEvent {
  const ClearCompletedTasks();
}
