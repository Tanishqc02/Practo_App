import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Health records'),
            bottom: const TabBar(tabs: [Tab(text: 'Vault'), Tab(text: 'Vitals')]),
          ),
          body: const TabBarView(children: [_Vault(), VitalsBody()]),
        ),
      );
}

IconData _catIcon(String c) => switch (c) {
      'Lab Reports' => Icons.biotech_rounded,
      'Prescriptions' => Icons.description_rounded,
      'Imaging' => Icons.image_rounded,
      'Bills' => Icons.receipt_long_rounded,
      _ => Icons.insert_drive_file_rounded,
    };

class _Vault extends StatefulWidget {
  const _Vault();
  @override
  State<_Vault> createState() => _VaultState();
}

class _VaultState extends State<_Vault> {
  String cat = 'All';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.records.where((r) => cat == 'All' || r.category == cat).toList();
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
              onPressed: () => _upload(context),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload'),
            ),
            body: Column(children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: 56,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                  for (final c in ['All', ...recordCategories])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(c == 'All' ? 'All (${app.records.length})' : '$c (${app.records.where((r) => r.category == c).length})'),
                        selected: cat == c,
                        selectedColor: kBlue,
                        showCheckmark: false,
                        labelStyle: TextStyle(color: cat == c ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 13),
                        onSelected: (_) => setState(() => cat = c),
                      ),
                    ),
                ]),
              ),
              Container(
                width: double.infinity,
                color: kCyan.withValues(alpha: .1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(children: [
                  Icon(Icons.lock_rounded, size: 15, color: kBlue),
                  SizedBox(width: 6),
                  Expanded(child: Text('Your vault is private to you. (Demo stores metadata on-device in memory.)', style: TextStyle(fontSize: 12, color: kBlue))),
                ]),
              ),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(Icons.folder_open_rounded, 'Nothing here yet', 'Upload reports, scans and bills to keep them in one place.')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final r = list[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: kBlue.withValues(alpha: .1), child: Icon(_catIcon(r.category), color: kBlue)),
                              title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${r.category} · ${fmtDateLong(r.date)} · ${r.sizeKb >= 1024 ? '${(r.sizeKb / 1024).toStringAsFixed(1)} MB' : '${r.sizeKb} KB'}'),
                              trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: kMuted), onPressed: () => app.removeRecord(r)),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          );
        },
      );

  void _upload(BuildContext context) {
    final name = TextEditingController();
    var c = cat == 'All' ? recordCategories.first : cat;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Upload to vault'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'File name (e.g. MRI_scan.pdf)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: c,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [for (final x in recordCategories) DropdownMenuItem(value: x, child: Text(x))],
              onChanged: (v) => setS(() => c = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final n = name.text.trim();
                if (n.isEmpty) return;
                app.addRecord(n, c, 640);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Vitals ─────────────────────────
class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Vitals tracker')), body: const VitalsBody());
}

class VitalsBody extends StatefulWidget {
  const VitalsBody({super.key});
  @override
  State<VitalsBody> createState() => _VitalsBodyState();
}

class _VitalsBodyState extends State<VitalsBody> {
  VitalType type = VitalType.bp;

  static String _unit(VitalType t) => switch (t) { VitalType.bp => 'mmHg', VitalType.sugar => 'mg/dL', VitalType.weight => 'kg' };

  (String, Color) _status(VitalType t, Vital v) {
    switch (t) {
      case VitalType.bp:
        if (v.v >= 140 || v.v2! >= 90) return ('High', kRed);
        if (v.v >= 130 || v.v2! >= 85) return ('Elevated', kAmber);
        return ('Normal', kGreen);
      case VitalType.sugar:
        if (v.v >= 126) return ('High', kRed);
        if (v.v >= 100) return ('Elevated', kAmber);
        return ('Normal', kGreen);
      case VitalType.weight:
        return ('Logged', kBlue);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final data = app.vitals[type]!;
          final last = data.last;
          final (label, color) = _status(type, last);
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: kBlue,
              foregroundColor: Colors.white,
              onPressed: () => _add(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add reading'),
            ),
            body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), children: [
              SegmentedButton<VitalType>(
                segments: const [
                  ButtonSegment(value: VitalType.bp, icon: Icon(Icons.favorite_rounded), label: Text('BP')),
                  ButtonSegment(value: VitalType.sugar, icon: Icon(Icons.bloodtype_rounded), label: Text('Sugar')),
                  ButtonSegment(value: VitalType.weight, icon: Icon(Icons.monitor_weight_rounded), label: Text('Weight')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setState(() => type = s.first),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Latest reading', style: TextStyle(color: kMuted)),
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: type == VitalType.bp ? '${last.v.round()}/${last.v2!.round()}' : last.v.toStringAsFixed(type == VitalType.weight ? 1 : 0),
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                          TextSpan(text: ' ${_unit(type)}', style: const TextStyle(color: kMuted)),
                        ])),
                        Text(DateFormat('d MMM, h:mm a').format(last.t), style: const TextStyle(color: kMuted, fontSize: 12)),
                      ]),
                    ),
                    Tag(label, color: color),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 18, 18, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 12),
                      child: Row(children: [
                        Text(switch (type) { VitalType.bp => 'Blood pressure trend', VitalType.sugar => 'Blood sugar trend', VitalType.weight => 'Weight trend' },
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                        const Spacer(),
                        if (type == VitalType.bp) ...[
                          const Icon(Icons.circle, size: 9, color: kRed), const Text(' Sys  ', style: TextStyle(fontSize: 12)),
                          const Icon(Icons.circle, size: 9, color: kBlue), const Text(' Dia', style: TextStyle(fontSize: 12)),
                        ],
                      ]),
                    ),
                    SizedBox(height: 230, child: LineChart(_chart(data))),
                  ]),
                ),
              ),
              const SectionTitle('History'),
              for (final v in data.reversed.take(8))
                Card(
                  child: ListTile(
                    dense: true,
                    title: Text(type == VitalType.bp ? '${v.v.round()}/${v.v2!.round()} ${_unit(type)}' : '${v.v.toStringAsFixed(type == VitalType.weight ? 1 : 0)} ${_unit(type)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(DateFormat('d MMM yyyy, h:mm a').format(v.t)),
                    trailing: Tag(_status(type, v).$1, color: _status(type, v).$2),
                  ),
                ),
            ]),
          );
        },
      );

  LineChartData _chart(List<Vital> data) {
    final first = data.first.t;
    double x(Vital v) => v.t.difference(first).inHours / 24;
    final s1 = [for (final v in data) FlSpot(x(v), v.v)];
    final s2 = type == VitalType.bp ? [for (final v in data) FlSpot(x(v), v.v2!)] : <FlSpot>[];
    final all = [...s1, ...s2].map((e) => e.y);
    final lo = all.reduce((a, b) => a < b ? a : b), hi = all.reduce((a, b) => a > b ? a : b);
    final pad = (hi - lo) * .2 + 2;
    LineChartBarData line(List<FlSpot> s, Color c) => LineChartBarData(
          spots: s,
          isCurved: true,
          color: c,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: s == s1 && type != VitalType.bp, color: c.withValues(alpha: .1)),
        );
    return LineChartData(
      minY: (lo - pad).floorToDouble(),
      maxY: (hi + pad).ceilToDouble(),
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, m) => Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 11, color: kMuted)))),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                reservedSize: 28,
                getTitlesWidget: (v, m) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(DateFormat('d MMM').format(first.add(Duration(days: v.round()))), style: const TextStyle(fontSize: 11, color: kMuted)),
                    ))),
      ),
      lineBarsData: [line(s1, type == VitalType.bp ? kRed : kBlue), if (s2.isNotEmpty) line(s2, kBlue)],
    );
  }

  void _add(BuildContext context) {
    final a = TextEditingController(), b = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${switch (type) { VitalType.bp => 'blood pressure', VitalType.sugar => 'blood sugar', VitalType.weight => 'weight' }}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: a, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: type == VitalType.bp ? 'Systolic (mmHg)' : 'Value (${_unit(type)})')),
          if (type == VitalType.bp) ...[
            const SizedBox(height: 10),
            TextField(controller: b, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Diastolic (mmHg)')),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(a.text), v2 = double.tryParse(b.text);
              if (v == null || (type == VitalType.bp && v2 == null)) return;
              app.addVital(type, v, v2);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
