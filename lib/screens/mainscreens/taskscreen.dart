import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/provider/taskprovider.dart';
import 'package:trek_list/screens/mainscreens/taskeditorscreen.dart';

class taskscreen_all extends ConsumerWidget {
  const taskscreen_all({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: const Color(0xFF0047AB),
      ),
      body: allAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }

          // ✅ Make a mutable copy before sorting
          final sortedTasks = [...tasks];
          sortedTasks.sort((a, b) {
            final da = a['due_date'] ?? '';
            final db = b['due_date'] ?? '';
            return da.compareTo(db);
          });

          return ListView.builder(
            itemCount: sortedTasks.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (c, i) {
              final t = sortedTasks[i];
              final priority = t['priority'] ?? 2;
              return Dismissible(
                key: ValueKey(t['id']),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await ref
                      .read(tasksProvider(t['list_id'] as int).notifier)
                      .deleteTask(t['id']);
                  ref.invalidate(allTasksProvider);
                },
                child: Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: (t['status'] ?? 1) == 3,
                      onChanged: (_) async {
                        await ref
                            .read(tasksProvider(t['list_id'] as int).notifier)
                            .toggleTask(t['id']);
                        ref.invalidate(allTasksProvider);
                      },
                    ),
                    title: Text(t['title'] ?? ''),
                    subtitle: Text(t['description'] ?? ''),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t['due_date'] ?? '',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priority == 1
                                ? Colors.red
                                : priority == 2
                                    ? Colors.blue
                                    : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority == 1
                                ? 'High'
                                : priority == 2
                                    ? 'Medium'
                                    : 'Low',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => taskeditor(
                            listId: t['list_id'] as int,
                            existingTask: t,
                          ),
                        ),
                      );
                      ref.invalidate(allTasksProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const taskeditor()),
          );
          ref.invalidate(allTasksProvider);
        },
        backgroundColor: const Color(0xFF0047AB),
        child: const Icon(Icons.add),
      ),
    );
  }
}
