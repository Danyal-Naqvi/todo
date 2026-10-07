import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';

class CreateTaskModal extends StatefulWidget {
  final Function(Task newTask) onTaskCreated;

  const CreateTaskModal({super.key, required this.onTaskCreated});

  static Future<void> show(
    BuildContext context, {
    required Function(Task newTask) onTaskCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskModal(onTaskCreated: onTaskCreated),
    );
  }

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _titleController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Design';
  bool _getAlert = true;

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
    _assigneeController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      subtitle: _selectedCategory == 'Design'
          ? 'Digital Product Design'
          : 'Software Engineering',
      description: _detailsController.text.trim(),
      category: _selectedCategory,
      priority: TaskPriority.high,
      dueDate: _selectedDate,
      dueTime: DateFormat('hh:mm a').format(DateTime.now()),
      timeRange: '${DateFormat('hh.mm a').format(_selectedDate)} - ${DateFormat('hh.mm a').format(_selectedDate.add(const Duration(hours: 1)))}',
      createdAt: DateTime.now(),
      status: 'In Process',
      customProgress: 0.0,
      assigneeName: _assigneeController.text.trim().isNotEmpty
          ? _assigneeController.text.trim()
          : 'Bruce Wayne',
      hasReminder: _getAlert,
    );

    widget.onTaskCreated(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                color: const Color(0xFFDCDFE5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Top action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: NeoBrutalist.iconButton(),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: NeoBrutalist.iconButton(),
                  child: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textPrimary,
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
                  const Text(
                    'New Tasks',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Task Title field
                  _buildPillInput(
                    controller: _titleController,
                    hintText: '| Task Title',
                  ),
                  const SizedBox(height: 14),

                  // Date field
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: NeoBrutalist.card(
                        borderRadius: 16,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(0, 3.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '| ${DateFormat('dd MMMM yyyy').format(_selectedDate)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Assignee field
                  _buildPillInput(
                    controller: _assigneeController,
                    hintText: '| Assignee',
                    suffixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Details area
                  Container(
                    decoration: NeoBrutalist.card(
                      borderRadius: 16,
                      borderWidth: 1.5,
                      shadowOffset: const Offset(0, 3.5),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _detailsController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add your task details',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Formatting tools bar
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 14),
                            const Text(
                              'A',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.attach_file_rounded,
                                size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category Section
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                                ? const Color(0xFFE8EBEE)
                                : const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.borderBlack
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
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Get alert toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Get alert for this task',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: _getAlert,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                        onChanged: (val) => setState(() => _getAlert = val),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Create Task Button
                  GestureDetector(
                    onTap: _saveTask,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x35FA6551),
                            offset: Offset(0, 4),
                            blurRadius: 10,
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillInput({
    required TextEditingController controller,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: NeoBrutalist.card(
        borderRadius: 16,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
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
}
