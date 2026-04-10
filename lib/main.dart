import 'package:flutter/material.dart';

import 'controller.dart';
import 'logic.dart';
import 'models.dart';

const int heatmapDaysCount = 84;
const int heatmapWeekColumns = 12;
const int heatmapRowsPerWeek = 7;

void main() {
  runApp(const DayTrackerApp());
}

class DayTrackerApp extends StatelessWidget {
  const DayTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0B11),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF00C8),
          tertiary: Color(0xFF39FF14),
          surface: Color(0xFF131624),
        ),
      ),
      home: const TrackerHome(),
    );
  }
}

class TrackerHome extends StatefulWidget {
  const TrackerHome({super.key});

  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> with SingleTickerProviderStateMixin {
  late final TrackerController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = TrackerController()..initialize();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Day Tracker'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Journal'),
                Tab(text: 'Heatmap'),
                Tab(text: 'Streaks'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _controller.loading ? null : () => _pickDate(context),
                icon: const Icon(Icons.calendar_month_rounded),
              ),
            ],
          ),
          body: _controller.loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _JournalTab(controller: _controller),
                    _HeatmapTab(controller: _controller),
                    _StreakTab(controller: _controller),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Category'),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      await _controller.pickDate(selected);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final colors = <Color>[
      const Color(0xFF00E5FF),
      const Color(0xFFFF00C8),
      const Color(0xFF39FF14),
      const Color(0xFFFF6D00),
      const Color(0xFF9D00FF),
    ];
    Color selected = colors.first;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: colors
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setState(() => selected = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected == c ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await _controller.addCategory(name: nameController.text, color: selected);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _JournalTab extends StatelessWidget {
  const _JournalTab({required this.controller});

  final TrackerController controller;

  @override
  Widget build(BuildContext context) {
    final dateLabel = TrackerLogic.dateKey(controller.selectedDate);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  'Selected day: $dateLabel',
                  key: ValueKey(dateLabel),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Planned')),
                  ButtonSegment(value: true, label: Text('Actual (end of day)')),
                ],
                selected: {controller.editActual},
                onSelectionChanged: (value) => controller.toggleMode(value.first),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              return _HourRow(
                hour: index,
                record: controller.selectedRecord.hours[index],
                categories: controller.categories,
                editActual: controller.editActual,
                onChanged: (id) => controller.setHourCategory(hour: index, categoryId: id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.hour,
    required this.record,
    required this.categories,
    required this.editActual,
    required this.onChanged,
  });

  final int hour;
  final HourRecord record;
  final List<TrackerCategory> categories;
  final bool editActual;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = editActual ? record.actualCategoryId : record.plannedCategoryId;
    final label = '${hour.toString().padLeft(2, '0')}:00';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(label),
        subtitle: DropdownButtonFormField<String?>(
          value: value,
          decoration: const InputDecoration(border: InputBorder.none),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Not set')),
            ...categories.map((c) {
              return DropdownMenuItem<String?>(
                value: c.id,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _HeatmapTab extends StatelessWidget {
  const _HeatmapTab({required this.controller});

  final TrackerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.categories.isEmpty) {
      return const Center(child: Text('Create at least one category to view heatmaps.'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: controller.categories.map((c) => _CategoryHeatmapCard(controller: controller, category: c)).toList(),
    );
  }
}

class _CategoryHeatmapCard extends StatelessWidget {
  const _CategoryHeatmapCard({
    required this.controller,
    required this.category,
  });

  final TrackerController controller;
  final TrackerCategory category;

  @override
  Widget build(BuildContext context) {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: heatmapDaysCount - 1));
    final days = <DateTime>[];
    for (int i = 0; i < heatmapDaysCount; i++) {
      final d = start.add(Duration(days: i));
      days.add(DateTime(d.year, d.month, d.day));
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: Color(category.colorValue), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeCategory(category.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(heatmapWeekColumns, (week) {
                    final weekDays = days.skip(week * heatmapRowsPerWeek).take(heatmapRowsPerWeek).toList();
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        children: weekDays.map((d) {
                          final hours = controller.hoursForCategoryOnDate(
                            categoryId: category.id,
                            date: d,
                            useActual: true,
                          );
                          final intensity = TrackerLogic.intensityFromHours(hours);
                          final base = Color(category.colorValue);
                          return Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: intensity == 0
                                  ? const Color(0xFF1C2137)
                                  : Color.lerp(const Color(0xFF1C2137), base, intensity),
                              boxShadow: intensity == 0
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: base.withOpacity(0.50),
                                        blurRadius: 6,
                                      ),
                                    ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakTab extends StatelessWidget {
  const _StreakTab({required this.controller});

  final TrackerController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.categories.isEmpty) {
      return const Center(child: Text('Create categories to unlock streaks.'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: controller.categories.map((c) {
        final streak = controller.streakForCategory(c.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131624),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(c.colorValue).withOpacity(0.75)),
            boxShadow: [
              BoxShadow(color: Color(c.colorValue).withOpacity(0.30), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Current streak: ${streak.current} day(s)'),
              Text('Best streak: ${streak.best} day(s)'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
