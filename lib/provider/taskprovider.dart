import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trek_list/data/database/taskdao.dart';

final tasksProvider = StateNotifierProvider.family<TasksNotifier, AsyncValue<List<Map<String, dynamic>>>, int>(
  (ref, listId) => TasksNotifier(listId),
);

final allTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dao = TasksDao();
  return await dao.getAllTasks();
});

final tasksForDateProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, dateKey) async {
  final dao = TasksDao();
  return await dao.getTasksForDate(dateKey);
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final int listId;
  final dao = TasksDao();
  TasksNotifier(this.listId) : super(const AsyncLoading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await dao.getTasks(listId);
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    await dao.insertTask(task);
    await loadTasks();
  }

  Future<void> updateTask(int id, Map<String, dynamic> task) async {
    await dao.updateTask(id, task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await dao.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTask(int id) async {
    // safer lookup without wrong orElse
    final currentList = state.value;
    if (currentList == null) return;
    final current = currentList.where((t) => t['id'] == id).toList();
    if (current.isEmpty) return;
    final c = current.first;
    await dao.toggleTaskCompletion(id, c['status'] ?? 1);
    await loadTasks();
  }
}
