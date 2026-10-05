import 'package:flutter/material.dart';
import '../art.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lab tests'),
            bottom: const TabBar(tabs: [Tab(text: 'Book tests'), Tab(text: 'My bookings'), Tab(text: 'Reports')]),
          ),
          body: const TabBarView(children: [_BookTab(), _BookingsTab(), _ReportsTab()]),
        ),
      );
}

class _BookTab extends StatelessWidget {
  const _BookTab();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final pkgs = labCatalog.where((t) => t.isPackage).toList();
          final tests = labCatalog.where((t) => !t.isPackage).toList();
          return Scaffold(
            bottomNavigationBar: app.labCart.isEmpty
                ? null
                : SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: kBorder))),
                      child: Row(children: [
                        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${app.labCart.length} selected', style: const TextStyle(color: kMuted)),
                          Text(inr(app.labSubtotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ]),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabCheckoutScreen())),
                          child: const Text('Schedule home collection'),
                        ),
                      ]),
                    ),
                  ),
            body: ListView(padding: const EdgeInsets.only(bottom: 16), children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kGreen, Color(0xFF3ACB9F)]),
                    borderRadius: BorderRadius.circular(16)),
                child: const Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Free home sample collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('On orders above ₹500 · NABL-certified labs', style: TextStyle(color: Colors.white70)),
                    ]),
                  ),
                  SizedBox(width: 10),
                  TestTubesArt(height: 62),
                ]),
              ),
              const SectionTitle('Health packages'),
              SizedBox(
                height: 212,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pkgs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final t = pkgs[i];
                    final sel = app.labCart.contains(t);
                    return SizedBox(
                      width: 230,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Tag('${t.tests} tests', color: kGreen),
                              const Spacer(),
                              if (t.fasting) const Tag('Fasting', color: kAmber),
                            ]),
                            const SizedBox(height: 8),
                            Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Expanded(child: Text(t.desc, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 12.5))),
                            Row(children: [
                              Text(i == 0 ? 'Starting ${inr(t.price)}' : inr(t.price),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              const Spacer(),
                              sel
                                  ? OutlinedButton(onPressed: () => app.toggleLab(t), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)), child: const Text('Added ✓'))
                                  : FilledButton(onPressed: () => app.toggleLab(t), style: FilledButton.styleFrom(minimumSize: const Size(0, 36)), child: const Text('Add')),
                            ]),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SectionTitle('Popular tests'),
              for (final t in tests)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Card(
                    child: ListTile(
                      title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${t.desc}${t.fasting ? ' · Fasting required' : ''}'),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(inr(t.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                        GestureDetector(
                          onTap: () => app.toggleLab(t),
                          child: Text(app.labCart.contains(t) ? 'Remove' : 'Add',
                              style: TextStyle(color: app.labCart.contains(t) ? kRed : kBlue, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ),
                  ),
                ),
            ]),
          );
        },
      );
}

class LabCheckoutScreen extends StatefulWidget {
  const LabCheckoutScreen({super.key});
  @override
  State<LabCheckoutScreen> createState() => _LabCheckoutScreenState();
}

class _LabCheckoutScreenState extends State<LabCheckoutScreen> {
  DateTime day = DateTime.now().add(const Duration(days: 1));
  int slotIdx = 1;
  final name = TextEditingController(text: app.userName);
  final addr = TextEditingController(text: '12, 4th Cross, Indiranagar, Bengaluru 560038');
  static const slots = [(6, '6:00 – 8:00 AM'), (8, '8:00 – 10:00 AM'), (10, '10:00 AM – 12:00 PM'), (16, '4:00 – 6:00 PM'), (18, '6:00 – 8:00 PM')];

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));
    final fasting = app.labCart.any((t) => t.fasting);
    return Scaffold(
      appBar: AppBar(title: const Text('Home sample collection')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton(
            onPressed: () {
              final s = slots[slotIdx];
              final b = app.bookLab(DateTime(day.year, day.month, day.day, s.$1), name.text.trim(), addr.text.trim());
              Navigator.pop(context);
              toast(context, 'Booked! Track ${b.id} under My bookings');
            },
            child: Text('Confirm & pay ${inr(app.labSubtotal + app.labCollectionFee)}'),
          ),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Tests', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        for (final t in app.labCart)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(t.name),
            trailing: Text(inr(t.price), style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        if (fasting)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: kAmber.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, color: kAmber),
              SizedBox(width: 8),
              Expanded(child: Text('Fast for 8–10 hours before sample collection. Water is allowed.')),
            ]),
          ),
        const SizedBox(height: 18),
        const Text('Collection date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final x = days[i];
              final sel = sameDay(x, day);
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => day = x),
                child: Container(
                  width: 62,
                  decoration: BoxDecoration(color: sel ? kBlue : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? kBlue : kBorder)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][x.weekday - 1], style: TextStyle(fontSize: 12, color: sel ? Colors.white70 : kMuted)),
                    Text('${x.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: sel ? Colors.white : null)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        const Text('Time slot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < slots.length; i++)
            ChoiceChip(
              label: Text(slots[i].$2),
              selected: slotIdx == i,
              selectedColor: kBlue,
              showCheckmark: false,
              labelStyle: TextStyle(color: slotIdx == i ? Colors.white : null, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => slotIdx = i),
            ),
        ]),
        const SizedBox(height: 18),
        const Text('Patient & address', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Patient name')),
        const SizedBox(height: 10),
        TextField(controller: addr, maxLines: 2, decoration: const InputDecoration(labelText: 'Collection address')),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              _line('Subtotal', inr(app.labSubtotal)),
              _line('Home collection', app.labCollectionFee == 0 ? 'FREE' : inr(app.labCollectionFee)),
              const Divider(),
              _line('Total', inr(app.labSubtotal + app.labCollectionFee), bold: true),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        const Center(child: Text('Demo checkout — no real payment is taken.', style: TextStyle(color: kMuted, fontSize: 12))),
      ]),
    );
  }

  Widget _line(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w800 : null))),
          Text(b, style: TextStyle(fontWeight: FontWeight.w800, color: b == 'FREE' ? kGreen : null)),
        ]),
      );
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => app.labBookings.isEmpty
            ? const EmptyState(Icons.science_outlined, 'No lab bookings', 'Book a test and track your home sample collection here.')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: app.labBookings.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final b = app.labBookings[i];
                  final done = b.stage == labStages.length - 1;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(b.tests.map((t) => t.name).join(', '), style: const TextStyle(fontWeight: FontWeight.w800))),
                          Text(inr(b.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.schedule_rounded, size: 16, color: kMuted),
                          const SizedBox(width: 4),
                          Text('${fmtDate(b.slot)} · ${fmtTime(b.slot)} (${b.id})', style: const TextStyle(color: kMuted)),
                        ]),
                        Row(children: [
                          const Icon(Icons.home_outlined, size: 16, color: kMuted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(b.address, style: const TextStyle(color: kMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 14),
                        StageTracker(stages: labStages, current: b.stage),
                        if (!done)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => app.advanceLab(b),
                              icon: const Icon(Icons.fast_forward_rounded, size: 18),
                              label: const Text('Simulate next step (demo)'),
                            ),
                          )
                        else
                          FilledButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LabReportScreen(app.reports.first))),
                            child: const Text('View report'),
                          ),
                      ]),
                    ),
                  );
                },
              ),
      );
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: app.reports.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = app.reports[i];
            final abnormal = r.values.where((v) => v.status != 'Normal').length;
            return Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0x1A1FA67A), child: Icon(Icons.description_rounded, color: kGreen)),
                title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${fmtDateLong(r.date)} · ${r.values.length} parameters'),
                trailing: abnormal == 0 ? const Tag('All normal', color: kGreen) : Tag('$abnormal flagged', color: kRed),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LabReportScreen(r))),
              ),
            );
          },
        ),
      );
}

class LabReportScreen extends StatelessWidget {
  final LabReport r;
  const LabReportScreen(this.r, {super.key});
  @override
  Widget build(BuildContext context) {
    final flagged = r.values.where((v) => v.status != 'Normal').length;
    return Scaffold(
      appBar: AppBar(title: const Text('Lab report')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(r.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        Text('${fmtDateLong(r.date)} · Patient: ${app.userName}', style: const TextStyle(color: kMuted)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: (flagged == 0 ? kGreen : kAmber).withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(flagged == 0 ? Icons.check_circle_rounded : Icons.warning_amber_rounded, color: flagged == 0 ? kGreen : kAmber),
            const SizedBox(width: 10),
            Expanded(child: Text(flagged == 0 ? 'All values are within the normal range.' : '$flagged value(s) outside the normal range. Consult your doctor.')),
          ]),
        ),
        const SizedBox(height: 12),
        for (final v in r.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(v.p.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Tag(v.status, color: v.status == 'Normal' ? kGreen : (v.status == 'High' ? kRed : kAmber)),
                  ]),
                  const SizedBox(height: 4),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '${v.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    TextSpan(text: ' ${v.p.unit}', style: const TextStyle(color: kMuted)),
                  ])),
                  const SizedBox(height: 6),
                  RangeBar(min: v.p.min, max: v.p.max, value: v.value),
                  Text('Normal range: ${v.p.min == 0 ? '<' : '${v.p.min} –'} ${v.p.max} ${v.p.unit}', style: const TextStyle(color: kMuted, fontSize: 12)),
                ]),
              ),
            ),
          ),
        const Text('Values shown are sample data for this demo and not medical advice.', style: TextStyle(color: kMuted, fontSize: 12)),
      ]),
    );
  }
}
