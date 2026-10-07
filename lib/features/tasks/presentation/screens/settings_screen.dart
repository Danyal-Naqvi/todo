import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFirebaseReady = FirebaseService.instance.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Cloud',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Firebase Cloud Sync Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isFirebaseReady
                    ? AppColors.priorityLow.withValues(alpha: 0.5)
                    : AppColors.priorityHigh.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isFirebaseReady
                          ? AppColors.priorityLow
                          : AppColors.priorityHigh)
                      .withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isFirebaseReady
                                ? AppColors.priorityLow
                                : AppColors.priorityHigh)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFirebaseReady
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_queue_rounded,
                        color: isFirebaseReady
                            ? AppColors.priorityLow
                            : AppColors.priorityHigh,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isFirebaseReady
                                ? 'Firebase Cloud Active'
                                : 'Offline-First Local Storage',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isFirebaseReady
                                ? 'Tasks automatically sync to Cloud Firestore in real-time.'
                                : 'Running in local reactive mode. Firebase ready for credentials!',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131622)
                        : const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined,
                          size: 16, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Text(
                        'User ID: ${FirebaseService.instance.activeUserId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showFirebaseConfigDialog(context),
                  icon: const Icon(Icons.settings_input_component_rounded,
                      size: 18),
                  label: const Text('Configure Firebase Credentials'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Theme Settings
          const Text(
            'APPEARANCE & THEME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.darkTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final currentIsDark = themeMode == ThemeMode.dark;
                    return SwitchListTile(
                      value: currentIsDark,
                      title: const Text(
                        'Obsidian Dark Mode',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Deep space contrast with neon accents',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.darkTextMuted),
                      ),
                      secondary: Icon(
                        currentIsDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                      ),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Task Management Actions
          const Text(
            'TASK MANAGEMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.darkTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_rounded,
                      color: AppColors.secondary),
                  title: const Text(
                    'Clear Completed Tasks',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Removes all completed tasks from the active list',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.darkTextMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    context.read<TaskBloc>().add(const ClearCompletedTasks());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completed tasks cleared! 🧹'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF131622)
                  : const Color(0xFFEFEFF5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TaskFlow Ultra v1.0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Powered by Flutter • BLoC Architecture • Cloud Firestore',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showFirebaseConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Firebase Setup'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To connect your Firebase project:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              '1. Run `flutterfire configure` in the terminal\n'
              '   OR\n'
              '2. Paste your project API Key & Project ID into `lib/firebase_options.dart` and set `isConfigured = true`.\n\n'
              'The app is currently running in offline-first mode with instant local caching!',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
