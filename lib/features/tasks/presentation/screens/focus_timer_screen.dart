import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class FocusTimerScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const FocusTimerScreen({super.key, this.onBackToHome});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  // Mode: 'pomodoro' (25 min), 'short_break' (5 min), 'long_break' (15 min)
  String _activeMode = 'pomodoro';

  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  // Daily productivity stats
  int _sessionsCompletedToday = 2;
  int _totalFocusMinutesToday = 50;
  final int _dailyGoalMinutes = 100;
  final int _dailyGoalSessions = 4;
  final int _streakDays = 4;

  Task? _selectedTask;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _switchMode(String mode) {
    _timer?.cancel();
    setState(() {
      _activeMode = mode;
      _isRunning = false;
      if (mode == 'pomodoro') {
        _totalSeconds = 25 * 60;
      } else if (mode == 'short_break') {
        _totalSeconds = 5 * 60;
      } else {
        _totalSeconds = 15 * 60;
      }
      _remainingSeconds = _totalSeconds;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          _onTimerComplete();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _addExtraFiveMinutes() {
    setState(() {
      _remainingSeconds += 5 * 60;
      _totalSeconds += 5 * 60;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('+5 minutes added to focus session ⏳'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onTimerComplete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    setState(() {
      _isRunning = false;
      if (_activeMode == 'pomodoro') {
        _sessionsCompletedToday++;
        _totalFocusMinutesToday += (_totalSeconds ~/ 60);
      }
      _remainingSeconds = _totalSeconds;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF191C24) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
              color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
              width: 2),
        ),
        title: Text(
          '🎉 Session Finished!',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          _activeMode == 'pomodoro'
              ? 'Awesome focus! You completed 25 minutes of deep work.'
              : 'Break time is over! Ready to get back into the zone?',
          style: TextStyle(
            color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          if (_activeMode == 'pomodoro')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _switchMode('short_break');
              },
              child: const Text('Take 5m Break',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _openTaskPicker(List<Task> activeTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF191C24) : AppColors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF383E4C)
                      : const Color(0xFFDCDFE5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Task to Focus On',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a task to track while your timer is running.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? const Color(0xFFA0A7B5)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Option for General Session
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor:
                  isDark ? const Color(0xFF222632) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E3342)
                      : AppColors.borderBlack,
                  width: 1.5,
                ),
              ),
              leading: const Icon(Icons.flash_on_rounded, color: AppColors.primary),
              title: Text(
                'General Focus (No specific task)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              onTap: () {
                setState(() => _selectedTask = null);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: activeTasks.isEmpty
                  ? Center(
                      child: Text(
                        'No uncompleted tasks found.\nAdd a task to link your session!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6E7482)
                              : AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: activeTasks.length,
                      itemBuilder: (context, index) {
                        final task = activeTasks[index];
                        final isSelected = _selectedTask?.id == task.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: NeoBrutalist.card(
                            context: context,
                            borderRadius: 16,
                            borderWidth: 1.5,
                            shadowOffset: const Offset(0, 2),
                          ),
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white
                                        : AppColors.textPrimary),
                              ),
                            ),
                            subtitle: Text(
                              task.category.isNotEmpty
                                  ? task.category
                                  : 'Personal',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFFA0A7B5)
                                    : AppColors.textSecondary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary)
                                : Icon(Icons.radio_button_unchecked,
                                    color: isDark
                                        ? const Color(0xFF6E7482)
                                        : AppColors.textMuted),
                            onTap: () {
                              setState(() => _selectedTask = task);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _markCurrentTaskDone() {
    if (_selectedTask == null) return;
    final updated = _selectedTask!.copyWith(
      isCompleted: true,
      status: 'Completed',
      completedAt: DateTime.now(),
    );
    context.read<TaskBloc>().add(UpdateTask(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Completed "${_selectedTask!.title}" 🎉'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.statusCompleted,
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() => _selectedTask = null);
  }

  String _formatTime(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _totalSeconds > 0
        ? (_totalSeconds - _remainingSeconds) / _totalSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            List<Task> activeTasks = [];
            if (state is TaskLoaded) {
              activeTasks = state.allTasks
                  .where((t) =>
                      !t.isCompleted &&
                      t.status.trim().toLowerCase() != 'completed' &&
                      t.status.trim().toLowerCase() != 'canceled')
                  .toList();
            }

            // Auto-select first active task if none selected
            if (_selectedTask == null && activeTasks.isNotEmpty) {
              _selectedTask = activeTasks.first;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (widget.onBackToHome != null) {
                            widget.onBackToHome!();
                          } else if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: NeoBrutalist.iconButton(context: context),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'Focus & Timer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resetTimer,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: NeoBrutalist.iconButton(context: context),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Mode Switcher Pills (Pomodoro / Short Break / Long Break)
                  _buildModeSelector(),

                  const SizedBox(height: 24),

                  // Linked Task Card (Currently Focusing On)
                  _buildLinkedTaskCard(activeTasks),

                  const SizedBox(height: 28),

                  // Circular Countdown Timer Display
                  _buildCircularTimer(progress),

                  const SizedBox(height: 28),

                  // Control Buttons (Start / Pause + Add 5 min)
                  _buildControls(),

                  const SizedBox(height: 32),

                  // Productivity & Daily Goal Stats
                  _buildDailyStatsSection(),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191C24) : const Color(0xFFE9EDF2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildModeTab('pomodoro', 'Pomodoro (25m)'),
          _buildModeTab('short_break', 'Short Break (5m)'),
          _buildModeTab('long_break', 'Long (15m)'),
        ],
      ),
    );
  }

  Widget _buildModeTab(String modeKey, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _activeMode == modeKey;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(modeKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF282D3A) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: isDark ? Colors.white : AppColors.borderBlack,
                    width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : AppColors.borderBlack,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.textPrimary)
                  : (isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedTaskCard(List<Task> activeTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 18,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FOCUSING ON',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF7E8696) : AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedTask != null
                      ? _selectedTask!.title
                      : 'General Focus Session',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Change Task Button
          GestureDetector(
            onTap: () => _openTaskPicker(activeTasks),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3342)
                        : const Color(0xFFD6DBE1),
                    width: 1),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (_selectedTask != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _markCurrentTaskDone,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white : AppColors.borderBlack,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularTimer(double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191C24) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : AppColors.borderBlack,
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress Indicator Ring
          SizedBox(
            width: 218,
            height: 218,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: isDark
                  ? const Color(0xFF222632)
                  : const Color(0xFFEFF2F5),
              valueColor: AlwaysStoppedAnimation<Color>(
                _activeMode == 'pomodoro'
                    ? AppColors.primary
                    : (_activeMode == 'short_break'
                        ? AppColors.statusCompleted
                        : AppColors.statusOnGoing),
              ),
            ),
          ),

          // Central Countdown Digits
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isRunning
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : (isDark
                          ? const Color(0xFF222632)
                          : const Color(0xFFF1F3F5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isRunning
                      ? (_activeMode == 'pomodoro'
                          ? 'Locking In ⚡'
                          : 'Resting ☕')
                      : 'Paused',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _isRunning
                        ? AppColors.primary
                        : (isDark
                            ? const Color(0xFFA0A7B5)
                            : AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // +5 Min Extra Button
        GestureDetector(
          onTap: _addExtraFiveMinutes,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: NeoBrutalist.card(
              context: context,
              borderRadius: 18,
              borderWidth: 1.5,
              shadowOffset: const Offset(0, 3),
            ),
            child: Row(
              children: [
                Icon(Icons.more_time_rounded,
                    size: 18,
                    color: isDark ? Colors.white : AppColors.textPrimary),
                const SizedBox(width: 6),
                Text(
                  '+5 min',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Main Play / Pause Button
        GestureDetector(
          onTap: _toggleTimer,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: _isRunning
                  ? (isDark ? const Color(0xFF2E3342) : AppColors.textPrimary)
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF383E4C) : AppColors.borderBlack,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.7)
                      : AppColors.borderBlack,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRunning ? 'Pause' : 'Start Focus',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStatsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyPercent =
        (_totalFocusMinutesToday / _dailyGoalMinutes).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 22,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Productivity Goal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF382312)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '$_streakDays Days Streak',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFFFB74D)
                            : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Linear Goal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: dailyPercent,
              minHeight: 10,
              backgroundColor: isDark
                  ? const Color(0xFF222632)
                  : const Color(0xFFECEFF3),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalFocusMinutesToday of $_dailyGoalMinutes mins completed',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFA0A7B5)
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${(dailyPercent * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 Metric Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricPill(
                  context: context,
                  icon: Icons.timer_outlined,
                  value: '$_totalFocusMinutesToday min',
                  label: 'Focus Time',
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricPill(
                  context: context,
                  icon: Icons.check_circle_outline_rounded,
                  value: '$_sessionsCompletedToday/$_dailyGoalSessions',
                  label: 'Sessions',
                  iconColor: AppColors.statusCompleted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricPill(
                  context: context,
                  icon: Icons.coffee_rounded,
                  value: '15 min',
                  label: 'Breaks',
                  iconColor: AppColors.statusOnGoing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222632) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3342) : const Color(0xFFE4E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF7E8696) : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
