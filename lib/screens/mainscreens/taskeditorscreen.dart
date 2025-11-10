import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/provider/listprovider.dart';
import 'package:trek_list/provider/taskprovider.dart';
import 'package:intl/intl.dart';

class taskeditor extends ConsumerStatefulWidget {
  final int? listId;
  final Map<String, dynamic>? existingTask;
  final DateTime? prefilledDate; // ✅ Added field for pre-filled date

  const taskeditor({
    super.key,
    this.listId,
    this.existingTask,
    this.prefilledDate, // ✅ Added in constructor
  });

  @override
  ConsumerState<taskeditor> createState() => _taskeditorState();
}

class _taskeditorState extends ConsumerState<taskeditor> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime? due;
  int priority = 2;
  String tagsCsv = '';
  int? selectedListId;

  @override
  void initState() {
    super.initState();

    if (widget.existingTask != null) {
      // 🟩 Editing existing task
      final t = widget.existingTask!;
      title = t['title'] ?? '';
      description = t['description'] ?? '';
      due = t['due_date'] != null ? DateTime.tryParse(t['due_date']) : null;
      priority = t['priority'] ?? 2;
      tagsCsv = t['tags'] ?? '';
      selectedListId = t['list_id'];
    } else {
      // 🟦 Creating new task
      selectedListId = widget.listId;
      due = widget.prefilledDate; // ✅ Prefill date if tapped from calendar
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Add Task' : 'Edit Task'),
        backgroundColor: const Color(0xFF0047AB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: listsAsync.when(
          data: (lists) {
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Title required' : null,
                    onSaved: (v) => title = v!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onSaved: (v) => description = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedListId,
                    items: lists
                        .map((l) => DropdownMenuItem(
                              value: l['id'] as int,
                              child: Text(l['name']),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedListId = v),
                    validator: (v) => v == null ? 'Select list' : null,
                    decoration: const InputDecoration(labelText: 'List'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          due == null
                              ? 'No due date selected'
                              : DateFormat.yMMMd().format(due!),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final d = await showDatePicker(
                            context: context,
                            initialDate: due ?? now,
                            firstDate:
                                now.subtract(const Duration(days: 3650)),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) setState(() => due = d);
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _choiceChip('High', 3, Colors.red),
                      const SizedBox(width: 8),
                      _choiceChip('Medium', 2, Colors.orange),
                      const SizedBox(width: 8),
                      _choiceChip('Low', 1, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: tagsCsv,
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)'),
                    onSaved: (v) => tagsCsv = v ?? '',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _choiceChip(String label, int val, Color col) {
    final selected = priority == val;
    return GestureDetector(
      onTap: () => setState(() => priority = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? col : col.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : col),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _formKey.currentState?.save();

    if (due == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select due date')),
      );
      return;
    }

    if (due!.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a valid future due date')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final map = {
      'list_id': selectedListId,
      'title': title,
      'description': description,
      'due_date': due!.toIso8601String(),
      'priority': priority,
      'status': widget.existingTask == null
          ? 1
          : (widget.existingTask!['status'] ?? 1),
      'tags': tagsCsv,
      'created_at': widget.existingTask == null
          ? now
          : (widget.existingTask!['created_at'] ?? now),
      'updated_at': now,
    };

    if (widget.existingTask == null) {
      await ref
          .read(tasksProvider(selectedListId!).notifier)
          .addTask(map);
    } else {
      await ref
          .read(tasksProvider(selectedListId!).notifier)
          .updateTask(widget.existingTask!['id'], map);
    }

    ref.invalidate(allTasksProvider);
    Navigator.pop(context);
  }
}
