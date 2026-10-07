import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../widgets/user_avatar_widget.dart';
import 'notification_screen.dart';

class BoardScreen extends StatefulWidget {
  final Task? task;

  const BoardScreen({super.key, this.task});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _searchController = TextEditingController();
  String _activeTab = 'On going';

  final List<Map<String, dynamic>> _ongoingCards = [
    {'title': 'Task Customization', 'comments': 12, 'hasBlueDot': true},
    {'title': 'Deadline Management', 'comments': 12, 'hasBlueDot': true},
    {'title': 'Networking Assistance', 'comments': 12, 'hasBlueDot': true},
    {'title': 'Data Security Assurance', 'comments': 12, 'hasBlueDot': true},
    {'title': 'Continuous Feedback Loop', 'comments': 0, 'hasBlueDot': true},
  ];

  final List<Map<String, dynamic>> _inProcessCards = [
    {'title': 'Application Tracking', 'comments': 12},
    {'title': 'Automated Job Alerts', 'comments': 12},
    {'title': 'Mobile Optimization', 'comments': 12},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNewCard() {
    showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'New Card',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            decoration: NeoBrutalist.inputDecoration(hintText: 'Card title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  setState(() {
                    _inProcessCards.add({
                      'title': textController.text.trim(),
                      'comments': 0,
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task?.title ?? 'Website for Rune.io';

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
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: NeoBrutalist.iconButton(),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                ],
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 14),

              // Team members & Deadline
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Team members',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AvatarStackWidget(
                          avatarSize: 30,
                          onAddTap: () {},
                        ),
                      ],
                    ),
                  ),
                  // Deadline Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E5E9),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_alarms_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Deadline: February 6',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search cards + Nav buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: NeoBrutalist.card(
                        borderRadius: 24,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(0, 3),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search cards',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // < > navigation pill
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: NeoBrutalist.card(
                      borderRadius: 24,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status Columns Header Tabs
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'On going'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.statusOnGoing,
                            borderRadius: BorderRadius.circular(14),
                            border: _activeTab == 'On going'
                                ? Border.all(color: Colors.black, width: 1.5)
                                : null,
                          ),
                          child: const Text(
                            'On going',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'In Process'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.statusInProcess,
                            borderRadius: BorderRadius.circular(14),
                            border: _activeTab == 'In Process'
                                ? Border.all(color: Colors.black, width: 1.5)
                                : null,
                          ),
                          child: const Text(
                            'In Process',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2-Column Cards Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: On going
                  Expanded(
                    child: Column(
                      children: _ongoingCards.map((card) {
                        return _buildKanbanCard(
                          title: card['title'] as String,
                          comments: card['comments'] as int,
                          hasBlueDot: card['hasBlueDot'] == true,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right Column: In Process
                  Expanded(
                    child: Column(
                      children: [
                        ..._inProcessCards.map((card) {
                          return _buildKanbanCard(
                            title: card['title'] as String,
                            comments: card['comments'] as int,
                            hasBlueDot: false,
                          );
                        }),

                        // Add new card dashed box
                        GestureDetector(
                          onTap: _addNewCard,
                          child: Container(
                            height: 64,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFCED3DA),
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanCard({
    required String title,
    required int comments,
    bool hasBlueDot = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: NeoBrutalist.card(
        borderRadius: 16,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              if (hasBlueDot) ...[
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.statusOnGoing,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          if (comments > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$comments Comments',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
