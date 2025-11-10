import 'package:trek_list/data/database/appbase.dart';

class ListsDao {
  final dbProvider = AppDatabase.instance;

  Future<List<Map<String, dynamic>>> getAllLists() async {
    final db = await dbProvider.database;
    return await db.query('lists', orderBy: 'created_at DESC');
  }

  Future<int> insertList(Map<String, dynamic> list) async {
    final db = await dbProvider.database;
    return await db.insert('lists', list);
  }

  Future<int> updateList(int id, Map<String, dynamic> list) async {
    final db = await dbProvider.database;
    return await db.update('lists', list, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteList(int id) async {
    final db = await dbProvider.database;
    return await db.delete('lists', where: 'id = ?', whereArgs: [id]);
  }
}
