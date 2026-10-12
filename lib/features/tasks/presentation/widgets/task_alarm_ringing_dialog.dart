import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/task_alarm_service.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import 'priority_badge.dart';

class TaskAlarmRingingDialog extends StatefulWidget {
  final Task task;
  final void Function(Task updatedTask)? onTaskUpdated;
  final VoidCallback? onStartWorking;
  final VoidCallback? onClose;

  const TaskAlarmRingingDialog({
    super.key,
    required this.task,
    this.onTaskUpdated,
    this.onStartWorking,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required Task task,
    void Function(Task updatedTask)? onTaskUpdated,
    VoidCallback? onStartWorking,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Task Alarm Ringing',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return TaskAlarmRingingDialog(
          task: task,
          onTaskUpdated: onTaskUpdated,
          onStartWorking: onStartWorking,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<TaskAlarmRingingDialog> createState() => _TaskAlarmRingingDialogState();
}

class _TaskAlarmRingingDialogState extends State<TaskAlarmRingingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _isMuted = TaskAlarmService.instance.isSoundMuted;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (!TaskAlarmService.instance.isInTest) {
      _animController.repeat();
    } else {
      _animController.value = 0.5;
    }
    TaskAlarmService.instance.ringingAlarmNotifier
        .addListener(_onExternalAlarmDismissed);
  }

  void _closeDialog() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onExternalAlarmDismissed() {
    if (TaskAlarmService.instance.activeAlarmTask == null && mounted) {
      _closeDialog();
    }
  }

  @override
  void dispose() {
    TaskAlarmService.instance.ringingAlarmNotifier
        .removeListener(_onExternalAlarmDismissed);
    _animController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      TaskAlarmService.instance.isSoundMuted = _isMuted;
    });
  }

  void _onStartTask() {
    TaskAlarmService.instance.startTaskNow(
      widget.task,
      onUpdateTask: (updated) {
        widget.onTaskUpdated?.call(updated);
      },
    );
    _closeDialog();
    widget.onStartWorking?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${widget.task.title}" is now On Going! 🚀'),
        backgroundColor: AppColors.statusOnGoing,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSnooze() {
    TaskAlarmService.instance.snooze(widget.task, minutes: 5);
    _closeDialog();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm snoozed for 5 minutes ⏳'),
        backgroundColor: AppColors.statusInProcess,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onDismiss() {
    TaskAlarmService.instance.dismiss(widget.task);
    _closeDialog();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alarm dismissed ✕'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;

    final displayTime = task.dueTime?.isNotEmpty == true
        ? task.dueTime!
        : (task.timeRange?.isNotEmpty == true
            ? task.timeRange!
            : 'Scheduled Time');

    return PopScope(
      canPop: false, // Must act on alarm buttons
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: NeoBrutalist.card(
            context: context,
            borderRadius: 24,
            borderWidth: 2.5,
            shadowOffset: const Offset(4, 6),
            backgroundColor: isDark ? const Color(0xFF181B23) : Colors.white,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header Banner with Alarm badge & Sound toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(21.5),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3342)
                          : AppColors.borderBlack,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.borderBlack, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'ALARM RINGING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.borderBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Mute / Unmute sound button
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.borderBlack, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              size: 15,
                              color: AppColors.borderBlack,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isMuted ? 'Muted' : 'Sound On',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.borderBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  children: [
                    // Animated Ringing Bell with Radar waves
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final waveVal = _animController.value;
                        final angle =
                            math.sin(_animController.value * math.pi * 6) *
                                0.14;

                        return SizedBox(
                          height: 96,
                          width: 96,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer expanding ripple
                              Transform.scale(
                                scale: 1.0 + (waveVal * 0.35),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: (1.0 - waveVal) * 0.7,
                                      ),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                              // Inner ripple
                              Transform.scale(
                                scale: 1.0 + (waveVal * 0.18),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(
                                      alpha: (1.0 - waveVal) * 0.18,
                                    ),
                                  ),
                                ),
                              ),
                              // Rocking Bell
                              Transform.rotate(
                                angle: angle,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.statusInProcess,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF2E3342)
                                          : AppColors.borderBlack,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withValues(alpha: 0.5)
                                            : AppColors.borderBlack,
                                        offset: const Offset(0, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.alarm_on_rounded,
                                    size: 34,
                                    color: AppColors.borderBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Title
                    Text(
                      'Time to Start Task! ⏰',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Your scheduled start time has arrived:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFA0A7B5)
                            : AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Task Info Neo Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222632)
                            : const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3342)
                              : const Color(0xFFE2E5E9),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusOnGoing
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.statusOnGoing,
                                  ),
                                ),
                              ),
                              PriorityBadge(priority: task.priority),
                              // Time
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1B1E26)
                                      : const Color(0xFFEDF0F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      size: 13,
                                      color: isDark
                                          ? const Color(0xFFA0A7B5)
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      displayTime,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (task.description.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? const Color(0xFFA0A7B5)
                                    : AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Primary Action: Start Task Now
                    GestureDetector(
                      onTap: _onStartTask,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: NeoBrutalist.button(
                          context: context,
                          backgroundColor: AppColors.primary,
                          borderRadius: 14,
                          borderWidth: 2,
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Start Task Now 🚀',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Row: Snooze & Dismiss
                    Row(
                      children: [
                        // Snooze 5m
                        Expanded(
                          child: GestureDetector(
                            onTap: _onSnooze,
                            child: Container(
                              height: 44,
                              decoration: NeoBrutalist.button(
                                context: context,
                                backgroundColor: AppColors.statusInProcess,
                                borderRadius: 12,
                                borderWidth: 1.5,
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.snooze_rounded,
                                      size: 16,
                                      color: AppColors.borderBlack,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Snooze (5m)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.borderBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dismiss
                        Expanded(
                          child: GestureDetector(
                            onTap: _onDismiss,
                            child: Container(
                              height: 44,
                              decoration: NeoBrutalist.button(
                                context: context,
                                backgroundColor: isDark
                                    ? const Color(0xFF222632)
                                    : const Color(0xFFEDF0F3),
                                borderRadius: 12,
                                borderWidth: 1.5,
                              ),
                              child: Center(
                                child: Text(
                                  'Dismiss ✕',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
