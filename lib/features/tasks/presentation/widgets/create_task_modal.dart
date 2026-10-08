import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';

class CreateTaskModal extends StatefulWidget {
  final Function(Task newTask) onTaskCreated;
  final DateTime? initialDate;
  final String? initialTime;

  const CreateTaskModal({
    super.key,
    required this.onTaskCreated,
    this.initialDate,
    this.initialTime,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(Task newTask) onTaskCreated,
    DateTime? initialDate,
    String? initialTime,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskModal(
        onTaskCreated: onTaskCreated,
        initialDate: initialDate,
        initialTime: initialTime,
      ),
    );
  }

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedCategory = 'Design';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = _parseInitialTime(widget.initialTime);
  }

  TimeOfDay _parseInitialTime(String? timeStr) {
    if (timeStr != null && timeStr.trim().isNotEmpty) {
      final clean = timeStr.toLowerCase().replaceAll('.', ':');
      final regex = RegExp(r'(\d{1,2})(?::(\d{1,2}))?\s*(am|pm)?');
      final match = regex.firstMatch(clean);
      if (match != null) {
        var hour = int.tryParse(match.group(1) ?? '') ?? 9;
        final minute = int.tryParse(match.group(2) ?? '') ?? 0;
        final period = match.group(3);
        if (period == 'pm' && hour < 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    final now = TimeOfDay.now();
    return TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  final List<String> _categories = [
    'Design',
    'Development',
    'Coding',
    'Meeting',
    'Office Time',
    'User Experience',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: Color(0xFF191C24),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: Color(0xFF191C24),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? const Color(0xFF191C24) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
                    width: 2),
              ),
              dialHandColor: AppColors.primary,
              dialBackgroundColor: isDark ? const Color(0xFF222632) : const Color(0xFFF5F6F8),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.statusCanceled,
        ),
      );
      return;
    }

    final taskDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final formattedTime = _formatTimeOfDay(_selectedTime);

    // Compute standard 1-hour window for timeRange
    final endDateTime = taskDateTime.add(const Duration(hours: 1));
    final startHour = (_selectedTime.hourOfPeriod == 0
            ? 12
            : _selectedTime.hourOfPeriod)
        .toString()
        .padLeft(2, '0');
    final startMin = _selectedTime.minute.toString().padLeft(2, '0');
    final startPeriod = _selectedTime.period == DayPeriod.am ? 'am' : 'pm';

    final endHourInt =
        endDateTime.hour % 12 == 0 ? 12 : endDateTime.hour % 12;
    final endHour = endHourInt.toString().padLeft(2, '0');
    final endMin = endDateTime.minute.toString().padLeft(2, '0');
    final endPeriod = endDateTime.hour >= 12 ? 'pm' : 'am';

    final timeRange =
        '$startHour.$startMin $startPeriod - $endHour.$endMin $endPeriod';

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      subtitle: _selectedCategory == 'Design'
          ? 'Digital Product Design'
          : 'Software Engineering',
      description: _detailsController.text.trim(),
      category: _selectedCategory,
      priority: TaskPriority.high,
      dueDate: taskDateTime,
      dueTime: formattedTime,
      timeRange: timeRange,
      createdAt: DateTime.now(),
      status: 'In Process',
      customProgress: 0.0,
      subtasks: const [],
      assigneeName: 'Bruce Wayne',
      hasReminder: false,
    );

    widget.onTaskCreated(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171E) : AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2E3342) : AppColors.borderBlack,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF383E4C) : const Color(0xFFDCDFE5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Top action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: NeoBrutalist.iconButton(context: context),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'New Tasks',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Task Title field
                  _buildPillInput(
                    context: context,
                    controller: _titleController,
                    hintText: '| Task Title',
                  ),
                  const SizedBox(height: 14),

                  // Date & Time Selectors Row
                  Row(
                    children: [
                      // Date Selector
                      Expanded(
                        flex: 6,
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 15),
                            decoration: NeoBrutalist.card(
                              context: context,
                              borderRadius: 16,
                              borderWidth: 1.5,
                              shadowOffset: const Offset(0, 3.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_selectedDate),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: isDark ? const Color(0xFFA0A7B5) : AppColors.textPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Time Selector
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 15),
                            decoration: NeoBrutalist.card(
                              context: context,
                              borderRadius: 16,
                              borderWidth: 1.5,
                              shadowOffset: const Offset(0, 3.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatTimeOfDay(_selectedTime),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: isDark ? const Color(0xFFA0A7B5) : AppColors.textPrimary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick Time Presets
                  _buildQuickTimePresets(context),
                  const SizedBox(height: 14),

                  // Objective Section
                  Text(
                    'Objective',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: NeoBrutalist.card(
                      context: context,
                      borderRadius: 16,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add objective',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF6E7482) : AppColors.textMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category Section
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF2E3342) : const Color(0xFFE8EBEE))
                                : (isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.borderBlack)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.textPrimary)
                                  : (isDark
                                      ? const Color(0xFFA0A7B5)
                                      : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Create Task Button
                  GestureDetector(
                    onTap: _saveTask,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? const Color(0xFF383E4C) : AppColors.borderBlack,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.6)
                                : const Color(0x35FA6551),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Create Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: NeoBrutalist.card(
        context: context,
        borderRadius: 16,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF6E7482) : AppColors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildQuickTimePresets(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final presets = [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: presets.map((t) {
          final isSelected =
              _selectedTime.hour == t.hour && _selectedTime.minute == t.minute;
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = t),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF222632) : const Color(0xFFF1F3F5)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.borderBlack)
                      : (isDark ? const Color(0xFF2E3342) : const Color(0xFFE2E5E8)),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                _formatTimeOfDay(t),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
