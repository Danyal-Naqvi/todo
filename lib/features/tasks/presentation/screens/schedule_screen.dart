import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../widgets/user_avatar_widget.dart';

class ScheduleScreen extends StatefulWidget {
  final VoidCallback? onAddSubtask;

  const ScheduleScreen({super.key, this.onAddSubtask});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 3; // Thu 17 by default

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'Mon', 'date': 14},
    {'day': 'Tue', 'date': 15},
    {'day': 'Wed', 'date': 16},
    {'day': 'Thu', 'date': 17},
    {'day': 'Fri', 'date': 18},
    {'day': 'Sat', 'date': 19},
    {'day': 'Sun', 'date': 20},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: NeoBrutalist.iconButton(),
                    child: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Wednesday, 17 January 2024',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 20),

              // Horizontal Date Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_weekDays.length, (index) {
                    final item = _weekDays[index];
                    final isSelected = index == _selectedDayIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['day'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item['date']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 28),

              // Timeline Schedule
              _buildTimeline(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        // 09 am slot
        _buildTimelineRow(
          timeLabel: '09 am',
          taskWidget: _buildScheduleCard(
            title: 'Optimize server response time.',
            timeRange: '09.00 am - 10.15 am',
          ),
        ),

        const SizedBox(height: 14),

        // 10 am slot
        _buildTimelineRow(
          timeLabel: '10 am',
          taskWidget: const SizedBox.shrink(),
        ),

        const SizedBox(height: 14),

        // 11 am slot (Team Meeting with avatars)
        _buildTimelineRow(
          timeLabel: '11 am',
          taskWidget: _buildTeamMeetingCard(),
        ),

        const SizedBox(height: 14),

        // 12 am slot
        _buildTimelineRow(
          timeLabel: '12 am',
          taskWidget: const SizedBox.shrink(),
        ),

        const SizedBox(height: 14),

        // 01 pm slot (with Add new subtask pill)
        _buildTimelineRow(
          timeLabel: '01 pm',
          taskWidget: _buildAddSubtaskButton(),
        ),

        const SizedBox(height: 14),

        // 02 pm slot
        _buildTimelineRow(
          timeLabel: '02 pm',
          taskWidget: const SizedBox.shrink(),
        ),

        const SizedBox(height: 14),

        // 03 pm slot
        _buildTimelineRow(
          timeLabel: '03 pm',
          taskWidget: _buildScheduleCard(
            title: 'Optimize Homepage Design',
            timeRange: '03.00 pm - 04.15 pm',
          ),
        ),

        const SizedBox(height: 14),

        // 04 pm slot
        _buildTimelineRow(
          timeLabel: '04 pm',
          taskWidget: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTimelineRow({
    required String timeLabel,
    required Widget taskWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 54,
          child: Text(
            timeLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: taskWidget),
      ],
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String timeRange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: NeoBrutalist.card(
        borderRadius: 18,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            timeRange,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMeetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: NeoBrutalist.card(
        borderRadius: 18,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Team Meeting\n(Designer and Developer)',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '10.45 am - 11.45 am',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          // Grey pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Optimization Website for Rune.io',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Avatars and arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AvatarStackWidget(avatarSize: 26),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubtaskButton() {
    return GestureDetector(
      onTap: widget.onAddSubtask,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: NeoBrutalist.card(
          borderRadius: 22,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add new subtask',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
