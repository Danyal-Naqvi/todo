import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/tasks/presentation/bloc/task_event.dart';
import '../../features/tasks/presentation/bloc/task_state.dart';
import '../../features/tasks/presentation/widgets/task_alarm_ringing_dialog.dart';
import 'task_alarm_service.dart';

class TaskAlarmHost extends StatefulWidget {
  final Widget child;

  const TaskAlarmHost({super.key, required this.child});

  @override
  State<TaskAlarmHost> createState() => _TaskAlarmHostState();
}

class _TaskAlarmHostState extends State<TaskAlarmHost> {
  @override
  void initState() {
    super.initState();
    TaskAlarmService.instance.onTaskUpdatedCallback = (updated) {
      if (mounted) {
        try {
          context.read<TaskBloc>().add(UpdateTask(updated));
        } catch (_) {}
      }
    };
    TaskAlarmService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (prev, curr) => curr is TaskLoaded,
      listener: (context, state) {
        if (state is TaskLoaded) {
          TaskAlarmService.instance.syncTasks(state.allTasks);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ValueListenableBuilder<Task?>(
            valueListenable: TaskAlarmService.instance.ringingAlarmNotifier,
            builder: (context, ringingTask, _) {
              if (ringingTask == null) return const SizedBox.shrink();

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.65),
                  alignment: Alignment.center,
                  child: TaskAlarmRingingDialog(
                    task: ringingTask,
                    onTaskUpdated: (updated) {
                      try {
                        context.read<TaskBloc>().add(UpdateTask(updated));
                      } catch (_) {}
                    },
                    onClose: () {
                      // Handled reactively by ringingAlarmNotifier
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
