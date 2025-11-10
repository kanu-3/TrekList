import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/provider/listprovider.dart';
import 'listeditor.dart';
import 'package:trek_list/screens/mainscreens/taskscreen.dart';

class listscreen extends ConsumerWidget {
  const listscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lists'),
        backgroundColor: const Color(0xFF0047AB),
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text('No lists yet. Create one.'));
          }

          return ListView.builder(
            itemCount: lists.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, i) {
              final l = lists[i];

              // Handle color parsing safely
              Color listColor;
              try {
                if (l['color'] != null && l['color'].toString().isNotEmpty) {
                  String colorString = l['color'].toString()
                      .replaceAll('#', '')
                      .replaceFirst('0x', '');
                  listColor = Color(int.parse('0xFF$colorString'));
                } else {
                  listColor = const Color(0xFF0047AB);
                }
              } catch (e) {
                listColor = const Color(0xFF0047AB);
              }

              return Card(
                child: ListTile(
                  title: Text(l['name']),
                  subtitle: Text(l['description'] ?? ''),
                  leading: Container(
                    width: 12,
                    height: 40,
                    color: listColor,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => listeditor(isEdit: true, list: l),
                          ),
                        );
                      } else if (v == 'delete') {
                        await ref
                            .read(listsProvider.notifier)
                            .deleteList(l['id']);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const taskscreen_all()),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => listeditor(isEdit: false)),
        ),
        backgroundColor: const Color(0xFF0047AB),
        child: const Icon(Icons.add),
      ),
    );
  }
}
