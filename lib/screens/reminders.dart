import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          // Today's schedule: flatten and sort by time.
          final slots = <(Reminder, TimeOfDay)>[
            for (final r in app.reminders) for (final t in r.times) (r, t),
          ]..sort((a, b) => (a.$2.hour * 60 + a.$2.minute).compareTo(b.$2.hour * 60 + b.$2.minute));
          final taken = slots.where((s) => app.isTaken(s.$1, s.$2)).length;
          return Scaffold(
            appBar: AppBar(title: const Text('Medicine reminders')),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
              onPressed: () => _add(context),
              icon: const Icon(Icons.add_alarm_rounded),
              label: const Text('Add reminder'),
            ),
            body: slots.isEmpty
                ? const EmptyState(Icons.alarm_off_rounded, 'No reminders', 'Add your medicines to never miss a dose.')
                : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Today: $taken of ${slots.length} doses taken', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(value: slots.isEmpty ? 0 : taken / slots.length, minHeight: 10, color: kGreen, backgroundColor: kBorder),
                          ),
                        ]),
                      ),
                    ),
                    const SectionTitle('Schedule'),
                    for (final s in slots)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: ListTile(
                            leading: PillImage(s.$1.shape, s.$1.color, size: 52),
                            title: Text(s.$1.name, style: TextStyle(fontWeight: FontWeight.w800, decoration: app.isTaken(s.$1, s.$2) ? TextDecoration.lineThrough : null)),
                            subtitle: Text('${s.$2.format(context)} · ${s.$1.dose}'),
                            trailing: app.isTaken(s.$1, s.$2)
                                ? IconButton(icon: const Icon(Icons.check_circle_rounded, color: kGreen, size: 30), onPressed: () => app.toggleTaken(s.$1, s.$2))
                                : FilledButton(
                                    onPressed: () => app.toggleTaken(s.$1, s.$2),
                                    style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
                                    child: const Text('Take'),
                                  ),
                          ),
                        ),
                      ),
                    const SectionTitle('All medicines'),
                    for (final r in app.reminders)
                      Dismissible(
                        key: ValueKey(r.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => app.removeReminder(r),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: PillImage(r.shape, r.color, size: 44),
                              title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(r.times.map((t) => t.format(context)).join(', ')),
                              trailing: const Text('swipe to delete', style: TextStyle(color: kMuted, fontSize: 11)),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Text('Reminders are shown in-app in this demo; push notifications need a notification plugin.', style: TextStyle(color: kMuted, fontSize: 12)),
                  ]),
          );
        },
      );

  void _add(BuildContext context) {
    final name = TextEditingController(), dose = TextEditingController(text: '1 tablet · after food');
    var shape = PillShape.round;
    var color = const Color(0xFFFFE7A0);
    final times = <TimeOfDay>[const TimeOfDay(hour: 9, minute: 0)];
    const palette = [Color(0xFFFFFFFF), Color(0xFFFFE7A0), Color(0xFFFFB3A7), Color(0xFFBFE3FF), Color(0xFFB6F0D4), Color(0xFFE3D4FF), Color(0xFFF5A623)];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('New reminder', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Medicine name')),
              const SizedBox(height: 10),
              TextField(controller: dose, decoration: const InputDecoration(labelText: 'Dose & instructions')),
              const SizedBox(height: 14),
              const Text('Pill look', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(children: [
                for (final s in PillShape.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => setS(() => shape = s),
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: shape == s ? kBlue : Colors.transparent, width: 2)),
                        child: PillImage(s, color, size: 56),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              Wrap(spacing: 10, children: [
                for (final c in palette)
                  GestureDetector(
                    onTap: () => setS(() => color = c),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: color == c ? kBlue : kBorder, width: color == c ? 3 : 1)),
                    ),
                  ),
              ]),
              const SizedBox(height: 14),
              const Text('Times', style: TextStyle(fontWeight: FontWeight.w700)),
              Wrap(spacing: 8, children: [
                for (final t in times) InputChip(label: Text(t.format(ctx)), onDeleted: times.length > 1 ? () => setS(() => times.remove(t)) : null),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('Add time'),
                  onPressed: () async {
                    final t = await showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 14, minute: 0));
                    if (t != null) setS(() => times.add(t));
                  },
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (name.text.trim().isEmpty) return;
                    times.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
                    app.addReminder(Reminder(app.nextId('RM'), name.text.trim(), dose.text.trim(), shape, color, List.of(times)));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save reminder'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
