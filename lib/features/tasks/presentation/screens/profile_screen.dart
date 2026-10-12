import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/user_avatar_widget.dart';
import 'edit_profile_screen.dart';
import 'task_overview_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        context.read<ProfileCubit>().updatePhotoFromFile(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated from gallery 📸'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.statusCompleted,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.statusCanceled,
          ),
        );
      }
    }
  }

  void _showAvatarOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF191C24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF383E4C)
                        : const Color(0xFFE0E3E8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a photo from your phone gallery or edit profile details',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? const Color(0xFFA0A7B5)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Material(
                color: isDark ? const Color(0xFF222632) : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3342)
                          : const Color(0xFFE2E6EC),
                      width: 1.5,
                    ),
                  ),
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primary, size: 24),
                  title: Text(
                    'Upload from Phone Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Select any image from your device photos',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFFA0A7B5)
                          : AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primary),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageFromGallery(context);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: isDark ? const Color(0xFF222632) : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3342)
                          : const Color(0xFFE2E6EC),
                      width: 1.5,
                    ),
                  ),
                  leading: const Icon(Icons.edit_note_rounded,
                      color: AppColors.statusOnGoing, size: 24),
                  title: Text(
                    'Edit Profile Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Update your name, bio, role & character avatar',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? const Color(0xFFA0A7B5)
                          : AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.statusOnGoing),
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToEditProfile(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF191C24) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
            width: 2,
          ),
        ),
        title: Text(
          'Clear Completed Tasks?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently remove all completed tasks from your workspace.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusCanceled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
                  width: 1.5,
                ),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TaskBloc>().add(const ClearCompletedTasks());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completed tasks cleared 🧹'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.textPrimary,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    UserProfile userProfile = const UserProfile();
    try {
      userProfile = context.watch<ProfileCubit>().state;
    } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            // Calculate real dynamic task stats from loaded tasks
            int inProcessCount = 0;
            int completedCount = 0;
            int ongoingCount = 0;
            int totalCount = 0;

            if (taskState is TaskLoaded) {
              final tasks = taskState.allTasks;
              totalCount = tasks.length;
              for (final t in tasks) {
                final s = t.status.trim().toLowerCase();
                if (t.isCompleted || s == 'completed') {
                  completedCount++;
                } else if (s == 'in process' || s == 'in_process') {
                  inProcessCount++;
                } else if (s == 'on going' || s == 'ongoing') {
                  ongoingCount++;
                }
              }
            }

            final completionRate = totalCount > 0
                ? ((completedCount / totalCount) * 100).toInt()
                : 0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            onBack?.call();
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
                        'My Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TaskOverviewScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: NeoBrutalist.iconButton(context: context),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            size: 22,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Stats & Center Avatar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Stat: Real In Process count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$inProcessCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'In Process tasks',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFA0A7B5)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center Avatar with camera edit badge
                      GestureDetector(
                        onTap: () => _showAvatarOptions(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            UserAvatarWidget.fromProfile(
                              userProfile,
                              size: 94,
                              showBorder: true,
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.borderBlack,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.6)
                                        : AppColors.borderBlack,
                                    offset: const Offset(0, 1.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Stat: Real Completed count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$completedCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed tasks',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFA0A7B5)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    userProfile.name,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Role Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF222632)
                          : const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E3342)
                            : const Color(0xFFE2E6EC),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      userProfile.role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFA0A7B5)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  if (userProfile.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '"${userProfile.bio}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF7E8696)
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons Row: Gallery Photo & Edit Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Upload from Gallery button
                      GestureDetector(
                        onTap: () => _pickImageFromGallery(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 11),
                          decoration: NeoBrutalist.card(
                            context: context,
                            borderRadius: 16,
                            borderWidth: 1.5,
                            shadowOffset: const Offset(0, 2.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Gallery Photo',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Edit Profile Button
                      GestureDetector(
                        onTap: () => _navigateToEditProfile(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E3342)
                                  : AppColors.borderBlack,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.6)
                                    : AppColors.borderBlack,
                                offset: const Offset(0, 2.5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section 1: Personal Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: NeoBrutalist.card(
                      context: context,
                      borderRadius: 20,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded,
                                size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Personal Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: userProfile.email.isNotEmpty
                              ? userProfile.email
                              : 'Not specified',
                        ),
                        Divider(
                          height: 20,
                          color: isDark
                              ? const Color(0xFF262A36)
                              : const Color(0xFFF0F2F5),
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.work_outline_rounded,
                          label: 'Occupation',
                          value: userProfile.role,
                        ),
                        Divider(
                          height: 20,
                          color: isDark
                              ? const Color(0xFF262A36)
                              : const Color(0xFFF0F2F5),
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.shield_outlined,
                          label: 'Workspace Mode',
                          value: 'Personal • Local & Offline-First',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 2: Task Productivity Breakdown Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: NeoBrutalist.card(
                      context: context,
                      borderRadius: 20,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insights_rounded,
                                    size: 20, color: AppColors.statusCompleted),
                                const SizedBox(width: 8),
                                Text(
                                  'Productivity Overview',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF13362E)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$completionRate% Done',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.statusCompleted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStatPill(
                                context: context,
                                label: 'Total Tasks',
                                value: '$totalCount',
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniStatPill(
                                context: context,
                                label: 'On Going',
                                value: '$ongoingCount',
                                color: AppColors.statusOnGoing,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMiniStatPill(
                                context: context,
                                label: 'Completed',
                                value: '$completedCount',
                                color: AppColors.statusCompleted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Quick button to detailed stats
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TaskOverviewScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF222632)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E3342)
                                    : const Color(0xFFE2E6EC),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bar_chart_rounded,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'View Detailed Analytics & Charts',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 3: Workspace Actions Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: NeoBrutalist.card(
                      context: context,
                      borderRadius: 20,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings_suggest_rounded,
                                size: 20,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'Workspace Actions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action: Clear Completed Tasks
                        GestureDetector(
                          onTap: () => _confirmClearCompleted(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C1919)
                                  : const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF5A2222)
                                    : const Color(0xFFFFD7D7),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.delete_sweep_rounded,
                                    size: 18,
                                    color: AppColors.statusCanceled),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Clear Completed Tasks',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusCanceled,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AppColors.statusCanceled),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF7E8696) : AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatPill({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222632) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3342) : const Color(0xFFE4E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
