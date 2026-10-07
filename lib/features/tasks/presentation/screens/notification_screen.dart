import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../widgets/user_avatar_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _activeFilter = 'All';

  final List<Map<String, dynamic>> _todayNotifications = [
    {
      'id': 'notif-1',
      'isEmail': true,
      'sender': 'Automation',
      'time': '1 hr ago',
      'message': 'An email was sent to everyone on this board',
    },
    {
      'id': 'notif-2',
      'isEmail': false,
      'avatarInitial': 'LC',
      'avatarColor': const Color(0xFF42BAAE),
      'sender': 'Automation',
      'time': '1 hr ago',
      'message': 'Event date has arrived! An email was sent to @LaraCroft',
    },
    {
      'id': 'notif-3',
      'isEmail': false,
      'avatarInitial': 'BW',
      'avatarColor': const Color(0xFFFF9E44),
      'sender': 'Automation',
      'time': '1 hr ago',
      'message': 'A new documen was signed and added to your board',
    },
    {
      'id': 'notif-4',
      'isEmail': false,
      'avatarInitial': 'CK',
      'avatarColor': const Color(0xFF4D86F7),
      'sender': 'Automation',
      'time': '1 hr ago',
      'message':
          'Event date has arrived! Clark Kent assigned WBC-40 to you',
    },
  ];

  final List<Map<String, dynamic>> _yesterdayNotifications = [
    {
      'id': 'notif-5',
      'isEmail': true,
      'sender': 'Automation',
      'time': '1 hr ago',
      'message': 'An email was sent to everyone on this board',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  const Text(
                    'Notification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 10),
                  _buildFilterChip('Unread'),
                  const SizedBox(width: 10),
                  _buildFilterChip('I was mentioned'),
                ],
              ),

              const SizedBox(height: 24),

              // Today Header
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Today Notifications
              ..._todayNotifications.map((notif) {
                return _buildDismissibleCard(
                  key: ValueKey(notif['id']),
                  isEmail: notif['isEmail'] == true,
                  initial: notif['avatarInitial'] as String?,
                  avatarColor: notif['avatarColor'] as Color?,
                  sender: notif['sender'] as String,
                  time: notif['time'] as String,
                  message: notif['message'] as String,
                  onDismissed: () {
                    setState(() {
                      _todayNotifications
                          .removeWhere((item) => item['id'] == notif['id']);
                    });
                  },
                );
              }),

              const SizedBox(height: 20),

              // Yesterday Header
              const Text(
                'Yesterday',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              // Yesterday Notifications
              ..._yesterdayNotifications.map((notif) {
                return _buildDismissibleCard(
                  key: ValueKey(notif['id']),
                  isEmail: notif['isEmail'] == true,
                  initial: notif['avatarInitial'] as String?,
                  avatarColor: notif['avatarColor'] as Color?,
                  sender: notif['sender'] as String,
                  time: notif['time'] as String,
                  message: notif['message'] as String,
                  onDismissed: () {
                    setState(() {
                      _yesterdayNotifications
                          .removeWhere((item) => item['id'] == notif['id']);
                    });
                  },
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleCard({
    required Key key,
    required bool isEmail,
    String? initial,
    Color? avatarColor,
    required String sender,
    required String time,
    required String message,
    required VoidCallback onDismissed,
  }) {
    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: NeoBrutalist.card(
          borderRadius: 18,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon / Avatar
            if (isEmail)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F3F5),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Color(0xFFEA4335),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            else
              UserAvatarWidget(
                size: 36,
                initials: initial ?? 'BW',
                backgroundColor: avatarColor ?? const Color(0xFFFF9E44),
              ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '$sender • ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: time,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
