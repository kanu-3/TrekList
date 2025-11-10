import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trek_list/data/database/listdao.dart';

final listsProvider = StateNotifierProvider<ListsNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => ListsNotifier(),
);

class ListsNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final dao = ListsDao();
  ListsNotifier() : super(const AsyncLoading()) {
    loadLists();
  }

  Future<void> loadLists() async {
    try {
      final lists = await dao.getAllLists();
      state = AsyncData(lists);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addList(Map<String, dynamic> list) async {
    await dao.insertList(list);
    await loadLists();
  }

  Future<void> updateList(int id, Map<String, dynamic> list) async {
    await dao.updateList(id, list);
    await loadLists();
  }

  Future<void> deleteList(int id) async {
    await dao.deleteList(id);
    await loadLists();
  }
}
