import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/provider/listprovider.dart';
import 'package:trek_list/provider/taskprovider.dart';
import 'package:trek_list/screens/mainscreens/taskeditorscreen.dart';
import 'listeditor.dart';

class searchscreen extends ConsumerStatefulWidget {
  const searchscreen({super.key});
  @override ConsumerState<searchscreen> createState() => _searchscreenState();
}
class _searchscreenState extends ConsumerState<searchscreen> {
  String q = '';

  @override Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search'), backgroundColor: const Color(0xFF0047AB)),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by title or tags'), onChanged: (v) => setState(()=> q = v.trim()))),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          // tasks
          tasksAsync.when(
            data: (tasks) {
              final filtered = tasks.where((t){
                final title = (t['title'] ?? '').toString().toLowerCase();
                final tags = (t['tags'] ?? '').toString().toLowerCase();
                final ql = q.toLowerCase();
                return title.contains(ql) || tags.contains(ql);
              }).toList();
              return _section('Tasks', filtered.map((t) => ListTile(title: Text(t['title']), subtitle: Text(t['tags'] ?? ''), onTap: () async {
                // open task details (editor)
                await Navigator.push(context, MaterialPageRoute(builder: (_) => taskeditor(listId: t['list_id'] as int, existingTask: t)));
                ref.invalidate(allTasksProvider);
              })).toList());
            },
            loading: () => const SizedBox.shrink(),
            error: (e,_) => _section('Tasks', [ListTile(title: Text('Error: $e'))]),
          ),

          // lists
          listsAsync.when(
            data: (lists) {
              final filtered = lists.where((l){
                final name = (l['name'] ?? '').toString().toLowerCase();
                final ql = q.toLowerCase();
                return name.contains(ql);
              }).toList();
              return _section('Lists', filtered.map((l) => ListTile(title: Text(l['name']), subtitle: Text(l['description'] ?? ''), onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => listeditor(isEdit: true, list: l)));
                ref.invalidate(listsProvider);
              })).toList());
            },
            loading: () => const SizedBox.shrink(),
            error: (e,_) => _section('Lists', [ListTile(title: Text('Error: $e'))]),
          ),

        ]))),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal:12, vertical:8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize:16, fontWeight: FontWeight.w600)),
      const SizedBox(height:6),
      ...children,
      const SizedBox(height: 12),
    ]));
  }
}
