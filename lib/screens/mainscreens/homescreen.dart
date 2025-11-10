import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trek_list/provider/taskprovider.dart';
import 'package:trek_list/screens/mainscreens/taskeditorscreen.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class homescreen extends ConsumerWidget {
  const homescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync =
        ref.watch(tasksForDateProvider(selectedDate.toIso8601String()));
    final allAsync = ref.watch(allTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEFE9E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        title: const Text(
          'TrekList Overview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: allAsync.when(
              data: (allTasks) {
                // 🔹 Group tasks by date for calendar markers
                final Map<DateTime, List<Map>> groupedTasks = {};
                for (var t in allTasks) {
                  if (t['due_date'] == null) continue;
                  final date = DateTime.tryParse(t['due_date']);
                  if (date == null) continue;
                  final key = DateTime(date.year, date.month, date.day);
                  groupedTasks.putIfAbsent(key, () => []).add(t);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📅 Calendar Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: selectedDate,
                        selectedDayPredicate: (day) =>
                            isSameDay(day, selectedDate),
                        onDaySelected: (selected, focused) async {
                          ref.read(selectedDateProvider.notifier).state = selected;
                          // 🟢 Directly open task editor on date click
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => taskeditor(prefilledDate: selected),
                            ),
                          );
                        },
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF0047AB),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF1E90FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),

                        // 🔵 Dots under dates for task colors
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final key = DateTime(date.year, date.month, date.day);
                            final tasksForDay = groupedTasks[key];
                            if (tasksForDay == null || tasksForDay.isEmpty) {
                              return const SizedBox();
                            }

                            // Use small colored dots for each task’s priority
                            final dots = tasksForDay.take(3).map((t) {
                              final p = t['priority'] ?? 2;
                              final color = p == 3
                                  ? Colors.red
                                  : p == 2
                                      ? Colors.orange
                                      : Colors.green;
                              return Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList();

                            return Padding(
                              padding: const EdgeInsets.only(top: 36.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: dots,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔔 Tasks for Selected Date
                    const Text(
                      "Tasks on this date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0047AB),
                      ),
                    ),
                    const SizedBox(height: 12),

                    tasksAsync.when(
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'No tasks for this date.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: tasks.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final t = tasks[index];
                            final priority = t['priority'] ?? 2;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  t['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(t['description'] ?? ''),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: priority == 3
                                        ? Colors.red
                                        : priority == 2
                                            ? Colors.orange
                                            : Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    priority == 3
                                        ? 'High'
                                        : priority == 2
                                            ? 'Medium'
                                            : 'Low',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),

                    const SizedBox(height: 24),

                    // ⏰ Due Soon Section
                    const Text(
                      "Due Soon (Next 48 hours)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0047AB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final now = DateTime.now();
                      final dueSoon = allTasks.where((task) {
                        final dueStr = task['due_date'];
                        if (dueStr == null || dueStr.isEmpty) return false;
                        final due = DateTime.tryParse(dueStr);
                        if (due == null) return false;
                        final diff = due.difference(now).inHours;
                        return diff >= 0 && diff <= 48;
                      }).toList();

                      if (dueSoon.isEmpty) {
                        return const Text(
                          "No urgent tasks. You’re good!",
                          style: TextStyle(color: Colors.black54),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dueSoon.length,
                        itemBuilder: (context, index) {
                          final task = dueSoon[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(task['title'] ?? ''),
                              subtitle: Text(
                                  'Due: ${task['due_date'] ?? ''} | Priority: ${task['priority'] ?? ''}'),
                            ),
                          );
                        },
                      );
                    }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ),
    );
  }
}
