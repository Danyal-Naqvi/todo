import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task_priority.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Stream<List<TaskModel>> streamTasks();
  Future<List<TaskModel>> getTasks();
  Future<void> saveTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<void> clearCompleted();
}

class SharedPreferencesTaskLocalDataSource implements TaskLocalDataSource {
  static const String _tasksPrefKey = 'taskflow_cached_tasks_v2';
  final _controller = StreamController<List<TaskModel>>.broadcast();
  List<TaskModel> _memoryTasks = [];
  bool _isInitialized = false;

  SharedPreferencesTaskLocalDataSource() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_tasksPrefKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(rawJson);
        _memoryTasks = list
            .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _memoryTasks = _getDefaultSampleTasks();
        await _persist();
      }
    } catch (_) {
      _memoryTasks = _getDefaultSampleTasks();
    }
    _isInitialized = true;
    _controller.add(List.unmodifiable(_memoryTasks));
  }

  List<TaskModel> _getDefaultSampleTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'rune-io',
        title: 'Website for Rune.io',
        subtitle: 'Digital Product Design',
        description:
            'Effectively manage and coordinate the tasks involved in the development and enhancement of the Rune.io job finder website. Ensure alignment with project goals, timelines, and quality standards.\n\nCollaborate with the design team to outline the requirements for the website redesign. Clearly define the visual elements, user interface improvements, and overall user experience enhancements.',
        category: 'Design',
        priority: TaskPriority.high,
        dueDate: now,
        dueTime: '10:45 am',
        timeRange: '10.45 am - 11.45 am',
        status: 'On going',
        customProgress: 0.40,
        createdAt: now.subtract(const Duration(hours: 4)),
        isPinned: true,
        tags: const ['Design', 'Website', 'Rune.io'],
        assigneeName: 'Jack Roberts',
        subtasks: const [
          SubTask(
            id: 'sub-1',
            title: 'Job Matching Optimization',
            isCompleted: true,
          ),
          SubTask(
            id: 'sub-2',
            title: 'Employer Dashboard Upgrades',
            isCompleted: false,
          ),
          SubTask(
            id: 'sub-3',
            title: 'Continuous Feedback Loop',
            isCompleted: false,
          ),
          SubTask(
            id: 'sub-4',
            title: 'Data Security Assurance',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'pro-savvy',
        title: 'Dashboard for ProSavvy',
        subtitle: 'Digital Product Design',
        description:
            'Craft intuitive analytics dashboards, interactive reporting charts, and streamline workspace navigation for enterprise customers.',
        category: 'Development',
        priority: TaskPriority.urgent,
        dueDate: now,
        dueTime: '09:00 am',
        timeRange: '09.00 am - 10.15 am',
        status: 'In Process',
        customProgress: 0.75,
        createdAt: now.subtract(const Duration(days: 1)),
        isPinned: true,
        hasReminder: true,
        isAlarmEnabled: true,
        tags: const ['Development', 'Analytics', 'Dashboard'],
        assigneeName: 'Bruce Wayne',
        subtasks: const [
          SubTask(
            id: 'ps-1',
            title: 'Optimize server response time.',
            isCompleted: true,
          ),
          SubTask(
            id: 'ps-2',
            title: 'Component Design Audit',
            isCompleted: true,
          ),
          SubTask(
            id: 'ps-3',
            title: 'Data caching layer',
            isCompleted: true,
          ),
          SubTask(
            id: 'ps-4',
            title: 'User role permission matrices',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'track-id',
        title: 'Mobile Apps for Track.id',
        subtitle: 'Digital Product Design',
        description:
            'Design and develop high performance native mobile experiences for real-time fleet GPS tracking and telemetry monitoring.',
        category: 'Coding',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 1)),
        dueTime: '02:00 pm',
        timeRange: '02.00 pm - 03.15 pm',
        status: 'In Process',
        customProgress: 0.50,
        createdAt: now.subtract(const Duration(days: 2)),
        tags: const ['Mobile', 'Tracking', 'Flutter'],
        assigneeName: 'Ava Taylor',
        subtasks: const [
          SubTask(
            id: 'tid-1',
            title: 'Real-time WebSocket connection',
            isCompleted: true,
          ),
          SubTask(
            id: 'tid-2',
            title: 'Background geolocation service',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'courier-go',
        title: 'Website for CourierGo.com',
        subtitle: 'Digital Product Design',
        description:
            'Revamp delivery scheduling flow, customer tracking portal, and shipment quotation calculator.',
        category: 'Design',
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 2)),
        dueTime: '03:00 pm',
        timeRange: '03.00 pm - 04.15 pm',
        status: 'On going',
        customProgress: 0.40,
        createdAt: now.subtract(const Duration(days: 3)),
        tags: const ['Logistics', 'Web', 'UI/UX'],
        assigneeName: 'Clark Kent',
        subtasks: const [
          SubTask(
            id: 'cg-1',
            title: 'Optimize Homepage Design',
            isCompleted: false,
          ),
        ],
      ),
      TaskModel(
        id: 'team-meeting-task',
        title: 'Team Meeting (Designer and Developer)',
        subtitle: 'Optimization Website for Rune.io',
        description:
            'Sync sprint deliverables, review design systems components, and test production deployment pipeline.',
        category: 'Meeting',
        priority: TaskPriority.high,
        dueDate: now,
        dueTime: '10:45 am',
        timeRange: '10.45 am - 11.45 am',
        status: 'In Process',
        customProgress: 0.60,
        createdAt: now.subtract(const Duration(hours: 2)),
        tags: ['Meeting', 'Sync'],
        assigneeName: 'Bruce Wayne',
      ),
      TaskModel(
        id: 'brand-style-guide',
        title: 'Brand Style Guide & Assets',
        subtitle: 'Digital Product Design',
        description:
            'Finalize color palettes, typography scale, Neo-Brutalist design tokens, and export exportable vector icon sets.',
        category: 'Design',
        priority: TaskPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
        dueTime: '05:00 pm',
        timeRange: '04.00 pm - 05.00 pm',
        status: 'Completed',
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 18)),
        customProgress: 1.0,
        createdAt: now.subtract(const Duration(days: 3)),
        tags: const ['Branding', 'Design System'],
        assigneeName: 'Jack Roberts',
        subtasks: const [
          SubTask(
            id: 'bg-1',
            title: 'Define primary & secondary color palettes',
            isCompleted: true,
          ),
          SubTask(
            id: 'bg-2',
            title: 'Export SVG icon pack',
            isCompleted: true,
          ),
        ],
      ),
      TaskModel(
        id: 'legacy-db-migration',
        title: 'Legacy Database Migration',
        subtitle: 'Digital Product Design',
        description:
            'Deprecated in favor of real-time cloud data pipelines. Migration scripts archived.',
        category: 'Development',
        priority: TaskPriority.low,
        dueDate: now.subtract(const Duration(days: 4)),
        dueTime: '11:00 am',
        timeRange: '11.00 am - 12.00 pm',
        status: 'Canceled',
        isCompleted: false,
        customProgress: 0.15,
        createdAt: now.subtract(const Duration(days: 6)),
        tags: const ['Database', 'Archived'],
        assigneeName: 'Bruce Wayne',
        subtasks: const [
          SubTask(
            id: 'lm-1',
            title: 'Export legacy tables schema',
            isCompleted: true,
          ),
        ],
      ),
    ];
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _memoryTasks.map((t) => t.toMap()).toList();
      await prefs.setString(_tasksPrefKey, jsonEncode(list));
    } catch (_) {}
    _controller.add(List.unmodifiable(_memoryTasks));
  }

  @override
  Stream<List<TaskModel>> streamTasks() async* {
    if (!_isInitialized) {
      await _init();
    }
    yield List.unmodifiable(_memoryTasks);
    yield* _controller.stream;
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    if (!_isInitialized) {
      await _init();
    }
    return List.unmodifiable(_memoryTasks);
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    if (!_isInitialized) await _init();
    final index = _memoryTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _memoryTasks[index] = task;
    } else {
      _memoryTasks.insert(0, task);
    }
    await _persist();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await saveTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (!_isInitialized) await _init();
    _memoryTasks.removeWhere((t) => t.id == taskId);
    await _persist();
  }

  @override
  Future<void> clearCompleted() async {
    if (!_isInitialized) await _init();
    _memoryTasks.removeWhere((t) => t.isCompleted);
    await _persist();
  }
}
