import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'consult.dart';
import 'home.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final f = app.filters;
          final results = app.searchDoctors();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Find doctors'),
              actions: [
                IconButton(
                  tooltip: 'My appointments',
                  icon: const Icon(Icons.event_note_rounded),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AppointmentsScreen())),
                ),
              ],
            ),
            body: Column(children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Column(children: [
                  TextField(
                    onChanged: (v) {
                      f.query = v;
                      app.refresh();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search doctor, speciality, clinic or area',
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: Badge(
                            isLabelVisible: f.active,
                            smallSize: 8,
                            child: const Icon(Icons.tune_rounded)),
                        onPressed: () => _filterSheet(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      _chip('Speciality', f.specialty, () => _pick(context, 'Speciality', specialties, f.specialty, (v) => f.specialty = v)),
                      _chip('Location', f.city, () => _pick(context, 'Location', cities, f.city, (v) => f.city = v)),
                      _chip('Availability', f.availability == 'Any' ? null : f.availability,
                          () => _pick(context, 'Availability', const ['Today', 'Tomorrow'], f.availability == 'Any' ? null : f.availability, (v) => f.availability = v ?? 'Any')),
                      _chip('Rating', f.minRating > 0 ? '${f.minRating}+' : null,
                          () => _pick(context, 'Minimum rating', const ['4.0+', '4.5+', '4.8+'], f.minRating > 0 ? '${f.minRating}+' : null,
                              (v) => f.minRating = v == null ? 0 : double.parse(v.replaceAll('+', '')))),
                      _chip('Consult type', f.tier?.label,
                          () => _pick(context, 'Consult type', [for (final t in Tier.values) '${t.label} · ${inr(t.fee)}'],
                              f.tier == null ? null : '${f.tier!.label} · ${inr(f.tier!.fee)}',
                              (v) => f.tier = v == null ? null : Tier.values.firstWhere((t) => v.startsWith(t.label)))),
                    ]),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                child: Row(children: [
                  Text('${results.length} doctors',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      f.sort = v;
                      app.refresh();
                    },
                    itemBuilder: (_) => [
                      for (final s in const ['Relevance', 'Rating', 'Fee', 'Experience'])
                        PopupMenuItem(value: s, child: Text('Sort: $s')),
                    ],
                    child: Row(children: [
                      const Icon(Icons.swap_vert_rounded, size: 18, color: kBlue),
                      Text(' ${f.sort}',
                          style: const TextStyle(color: kBlue, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                child: results.isEmpty
                    ? const EmptyState(Icons.search_off_rounded, 'No doctors found',
                        'Try changing the filters or search term.')
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => DoctorCard(results[i]),
                      ),
              ),
            ]),
          );
        },
      );

  Widget _chip(String label, String? value, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(
          onPressed: onTap,
          backgroundColor: value != null ? kBlue.withValues(alpha: .1) : Colors.white,
          side: BorderSide(color: value != null ? kBlue : kBorder),
          label: Text(value ?? label,
              style: TextStyle(
                  color: value != null ? kBlue : null,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          avatar: value != null ? const Icon(Icons.check, size: 16, color: kBlue) : null,
        ),
      );

  void _pick(BuildContext context, String title, List<String> options, String? current,
      void Function(String?) set) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          ListTile(
            title: const Text('Any'),
            trailing: current == null ? const Icon(Icons.check, color: kBlue) : null,
            onTap: () {
              set(null);
              app.refresh();
              Navigator.pop(context);
            },
          ),
          for (final o in options)
            ListTile(
              title: Text(o),
              trailing: current == o ? const Icon(Icons.check, color: kBlue) : null,
              onTap: () {
                set(o);
                app.refresh();
                Navigator.pop(context);
              },
            ),
        ]),
      ),
    );
  }

  void _filterSheet(BuildContext context) {
    final f = app.filters;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(f.active ? 'Filters are applied. Use the chips to change them.' : 'No filters applied.',
                style: const TextStyle(color: kMuted)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                f.reset();
                app.refresh();
                Navigator.pop(context);
              },
              child: const Text('Clear all filters'),
            ),
          ]),
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor d;
  const DoctorCard(this.d, {super.key});
  @override
  Widget build(BuildContext context) {
    final next = app.nextSlot(d);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(d))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              DoctorAvatar(d, size: 62),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(d.specialty,
                      style: const TextStyle(color: kBlue, fontWeight: FontWeight.w600)),
                  Text('${d.experience} yrs experience · ${d.qualifications.split(',').first}',
                      style: const TextStyle(color: kMuted, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Row(children: [
                    RatingChip(d.rating),
                    const SizedBox(width: 8),
                    Text('${d.ratings} patient stories',
                        style: const TextStyle(color: kMuted, fontSize: 12.5)),
                  ]),
                ]),
              ),
              if (d.tier == Tier.top) const Tag('TOP', color: kGold, icon: Icons.star_rounded),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: kMuted),
              const SizedBox(width: 4),
              Expanded(
                  child: Text('${d.clinic}, ${d.area}, ${d.city}',
                      style: const TextStyle(color: kMuted, fontSize: 12.5))),
            ]),
            const Divider(height: 20),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(inr(d.fee),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text('Consultation fee', style: TextStyle(color: kMuted, fontSize: 11.5)),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                    next == null ? 'No slots' : (sameDay(next, DateTime.now()) ? 'Today ${fmtTime(next)}' : fmtDateTime(next)),
                    style: TextStyle(
                        color: next != null && sameDay(next, DateTime.now()) ? kGreen : kBlue,
                        fontWeight: FontWeight.w700)),
                const Text('Next available', style: TextStyle(color: kMuted, fontSize: 11.5)),
              ]),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => ChatScreen(d))),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(d))),
                  child: const Text('Book now'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Doctor profile ─────────────────────────
class DoctorProfileScreen extends StatefulWidget {
  final Doctor d;
  const DoctorProfileScreen(this.d, {super.key});
  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late DateTime day = DateTime.now();
  DateTime? slot;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final days = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final slots = app.availableSlots(d, day);
        if (slot != null && !slots.contains(slot)) slot = null;
        List<DateTime> part(int from, int to) =>
            slots.where((s) => s.hour >= from && s.hour < to).toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Doctor profile')),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                  color: Colors.white, border: Border(top: BorderSide(color: kBorder))),
              child: Row(children: [
                OutlinedButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => ChatScreen(d))),
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: slot == null ? null : () => _bookSheet(context),
                    child: Text(slot == null
                        ? 'Select a slot to book'
                        : 'Book now · ${fmtDate(slot!)}, ${fmtTime(slot!)}'),
                  ),
                ),
              ]),
            ),
          ),
          body: ListView(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DoctorAvatar(d, size: 84),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(d.specialty,
                        style: const TextStyle(color: kBlue, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(d.qualifications, style: const TextStyle(color: kMuted)),
                    const SizedBox(height: 8),
                    Tag(d.tier.label, color: d.tier == Tier.top ? kGold : kBlue),
                  ]),
                ),
              ]),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
                _stat('${d.experience} yrs', 'Experience', Icons.workspace_premium_outlined),
                _stat('${(d.rating * 20).round()}%', 'Recommended', Icons.thumb_up_alt_outlined),
                _stat('${d.ratings}', 'Patient stories', Icons.rate_review_outlined),
              ]),
            ),
            const SectionTitle('Consultation fee'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.videocam_outlined, color: kBlue),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Video consultation / clinic visit')),
                      Text(inr(d.fee), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ]),
                    const Divider(height: 22),
                    Row(children: [
                      const Icon(Icons.chat_outlined, color: kBlue),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('Text chat')),
                      if (app.isPlus) ...[const PlusBadge(), const SizedBox(width: 6), const Text('FREE', style: TextStyle(color: kGreen, fontWeight: FontWeight.w800))]
                      else Text('${inr(kTextChatFee)} (free with Plus)', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
              ),
            ),
            const SectionTitle('Clinic / hospital'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.local_hospital_rounded, color: kBlue),
                  title: Text(d.clinic, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${d.area}, ${d.city}\nSpeaks: ${d.languages}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.directions_rounded, color: kBlue),
                ),
              ),
            ),
            const SectionTitle('Available slots'),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final x = days[i];
                  final sel = sameDay(x, day);
                  final n = app.availableSlots(d, x).length;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() {
                      day = x;
                      slot = null;
                    }),
                    child: Container(
                      width: 66,
                      decoration: BoxDecoration(
                        color: sel ? kBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? kBlue : kBorder),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][x.weekday - 1],
                            style: TextStyle(color: sel ? Colors.white70 : kMuted, fontSize: 12)),
                        Text('${x.day}',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: sel ? Colors.white : null)),
                        Text(n == 0 ? 'Off' : '$n slots',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: sel ? Colors.white70 : (n == 0 ? kRed : kGreen),
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No slots available on this day. Pick another date.', style: TextStyle(color: kMuted))),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (final g in [('Morning', part(0, 12)), ('Afternoon', part(12, 17)), ('Evening', part(17, 24))])
                    if (g.$2.isNotEmpty) ...[
                      Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: kMuted)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final s in g.$2)
                          ChoiceChip(
                            label: Text(fmtTime(s)),
                            selected: slot == s,
                            selectedColor: kBlue,
                            labelStyle: TextStyle(color: slot == s ? Colors.white : null, fontWeight: FontWeight.w600),
                            showCheckmark: false,
                            onSelected: (_) => setState(() => slot = s),
                          ),
                      ]),
                      const SizedBox(height: 12),
                    ],
                ]),
              ),
            const SectionTitle('Patient reviews'),
            for (final r in d.reviews)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: kCyan.withValues(alpha: .2), child: Text(r.name[0], style: const TextStyle(fontWeight: FontWeight.w800, color: kBlue))),
                        const SizedBox(width: 8),
                        Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text(r.date, style: const TextStyle(color: kMuted, fontSize: 12)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        for (var i = 0; i < 5; i++)
                          Icon(i < r.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 18, color: kAmber),
                        const SizedBox(width: 6),
                        const Tag('Verified patient', color: kGreen, icon: Icons.verified_rounded),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.text),
                    ]),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }

  Widget _stat(String v, String l, IconData i) => Expanded(
        child: Column(children: [
          Icon(i, color: kBlue),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text(l, style: const TextStyle(color: kMuted, fontSize: 12)),
        ]),
      );

  void _bookSheet(BuildContext context) {
    final d = widget.d;
    final s = slot!;
    var video = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Confirm appointment', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: DoctorAvatar(d, size: 46),
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${fmtDate(s)} · ${fmtTime(s)}'),
              ),
              const SizedBox(height: 6),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, icon: Icon(Icons.videocam_rounded), label: Text('Video')),
                  ButtonSegment(value: false, icon: Icon(Icons.local_hospital_rounded), label: Text('Clinic visit')),
                ],
                selected: {video},
                onSelectionChanged: (v) => setS(() => video = v.first),
              ),
              const SizedBox(height: 14),
              _row('${d.tier.label} consultation', inr(d.fee)),
              _row('Platform fee', '₹0'),
              const Divider(),
              _row('Total payable', inr(d.fee), bold: true),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  final a = app.book(d, s, video);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  tabIndex.value = 0;
                  toast(context, 'Booked with ${a.doctor.name} on ${fmtDateTime(a.time)}');
                },
                child: Text('Pay ${inr(d.fee)} & confirm'),
              ),
              const SizedBox(height: 6),
              const Center(child: Text('Demo checkout — no real payment is taken.', style: TextStyle(color: kMuted, fontSize: 12))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w800 : null))),
          Text(b, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 16 : null)),
        ]),
      );
}
