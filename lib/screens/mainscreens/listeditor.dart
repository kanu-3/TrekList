import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trek_list/provider/listprovider.dart';

class listeditor extends ConsumerStatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? list;
  const listeditor({super.key, required this.isEdit, this.list});

  @override ConsumerState<listeditor> createState() => _listeditorState();
}
class _listeditorState extends ConsumerState<listeditor> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String desc = '';
  String colorHex = Color(0xFF0047AB).value.toRadixString(16);

  @override void initState() {
    super.initState();
    if (widget.isEdit && widget.list != null) {
      name = widget.list!['name'] ?? '';
      desc = widget.list!['description'] ?? '';
      colorHex = widget.list!['color'] ?? colorHex;
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit List' : 'Create New List'), backgroundColor: const Color(0xFF0047AB)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'List Name'), validator: (v)=> (v==null||v.trim().isEmpty)?'Required':null, onSaved:(v)=>name=v!.trim()),
            const SizedBox(height: 12),
            TextFormField(initialValue: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines:3, onSaved:(v)=>desc=v ?? ''),
            const SizedBox(height: 12),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(spacing:8, children: [
              colorTile(const Color(0xFF0047AB)),
              colorTile(const Color(0xFFDD2C00)),
              colorTile(const Color(0xFF2E7D32)),
              colorTile(const Color(0xFF8E24AA)),
              colorTile(const Color(0xFFFF8F00)),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width:12),
              ElevatedButton(onPressed: _save, child: Text(widget.isEdit ? 'Update' : 'Create')),
            ])
          ]),
        ),
      ),
    );
  }

  Widget colorTile(Color c) {
    return GestureDetector(
      onTap: () => setState(() => colorHex = c.value.toRadixString(16)),
      child: Container(width:44, height:28, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6), border: Border.all(color: colorHex == c.value.toRadixString(16) ? Colors.black : Colors.transparent))),
    );
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _formKey.currentState?.save();
    final now = DateTime.now().toIso8601String();
    final map = {
      'name': name,
      'description': desc,
      'color': colorHex,
      'created_at': now,
      'updated_at': now,
    };
    if (widget.isEdit && widget.list != null) {
      await ref.read(listsProvider.notifier).updateList(widget.list!['id'], map);
    } else {
      await ref.read(listsProvider.notifier).addList(map);
    }
    Navigator.pop(context);
  }
}
