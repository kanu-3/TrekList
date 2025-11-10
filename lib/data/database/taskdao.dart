import 'package:trek_list/data/database/appbase.dart';

class TasksDao {
  final dbProvider = AppDatabase.instance;

  Future<List<Map<String, dynamic>>> getTasks(int listId) async {
    final db = await dbProvider.database;
    return await db.query(
      'tasks',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'due_date ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await dbProvider.database;
    return await db.query('tasks', orderBy: 'due_date ASC');
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await dbProvider.database;
    return await db.insert('tasks', task);
  }

  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await dbProvider.database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await dbProvider.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleTaskCompletion(int id, int currentStatus) async {
    final db = await dbProvider.database;
    final newStatus = (currentStatus == 3) ? 1 : (currentStatus + 1);
    return await db.update('tasks', {'status': newStatus, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTasksForDate(String dateKey) async {
    final db = await dbProvider.database;
    final rows = await db.query('tasks', where: "date(due_date) = date(?)", whereArgs: [dateKey], orderBy: 'priority DESC, due_date ASC');
    return rows;
  }
}
