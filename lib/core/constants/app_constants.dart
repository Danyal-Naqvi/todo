import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppConstants {
  static const String appName = 'TaskFlow Ultra';
  static const String tasksCollection = 'tasks';
  static const String usersCollection = 'users';

  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Work',
      'icon': Icons.work_outline_rounded,
      'color': AppColors.catWork,
    },
    {
      'name': 'Personal',
      'icon': Icons.person_outline_rounded,
      'color': AppColors.catPersonal,
    },
    {
      'name': 'Fitness',
      'icon': Icons.fitness_center_rounded,
      'color': AppColors.catFitness,
    },
    {
      'name': 'Study',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.catStudy,
    },
    {
      'name': 'Finance',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.catFinance,
    },
    {
      'name': 'Ideas',
      'icon': Icons.lightbulb_outline_rounded,
      'color': AppColors.catIdeas,
    },
  ];
}
