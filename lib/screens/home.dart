import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'consult.dart';
import 'plus.dart';
import 'prescription.dart';
import 'records.dart';
import 'reminders.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final upcoming = app.appointments.where((a) => a.status == 'Upcoming').toList()
            ..sort((a, b) => a.time.compareTo(b.time));
          return Scaffold(
            body: ListView(padding: EdgeInsets.zero, children: [
              _header(context),
              _plusBanner(context),
              _quickActions(context),
              if (app.refillSubscribed && app.nextRefill != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Card(
                    child: ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                          backgroundColor: Color(0x1A1FA67A),
                          child: Icon(Icons.autorenew_rounded, color: kGreen)),
                      title: const Text('Medicine refill coming up',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                          'Next monthly refill on ${fmtDateLong(app.nextRefill!)} · 5% off'),
                      onTap: () => tabIndex.value = 3,
                    ),
                  ),
                ),
              if (upcoming.isNotEmpty) ...[
                const SectionTitle('Upcoming appointments'),
                for (final a in upcoming)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: AppointmentCard(a)),
              ],
              SectionTitle('Today\'s medicines',
                  trailing: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RemindersScreen())),
                      child: const Text('See all'))),
              _reminderPreview(context),
              const SectionTitle('Consult top specialities'),
              _specialties(context),
              _healthTips(context),
              const SizedBox(height: 16),
            ]),
          );
        },
      );

  Widget _header(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [kBlue, Color(0xFF3F4DC4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.local_hospital_rounded, color: kCyan),
            const SizedBox(width: 6),
            const Text('practo',
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            if (app.isPlus) ...[const SizedBox(width: 8), const PlusBadge()],
            const Spacer(),
            PopupMenuButton<String>(
              initialValue: app.city,
              onSelected: (c) {
                app.city = c;
                app.refresh();
              },
              itemBuilder: (_) =>
                  [for (final c in cities) PopupMenuItem(value: c, child: Text(c))],
              child: Row(children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 2),
                Text(app.city,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hi ${app.userName},',
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const Text('How are you feeling today?',
                    style: TextStyle(
                        color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              height: 50,
              child: Stack(children: [
                for (var i = 0; i < 3; i++)
                  Positioned(
                    left: i * 16.0,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                      child: DoctorAvatar(doctors[[2, 1, 4][i]], size: 46),
                    ),
                  ),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => tabIndex.value = 1,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.search_rounded, color: kMuted),
                SizedBox(width: 10),
                Text('Search doctors, specialities, clinics',
                    style: TextStyle(color: kMuted)),
              ]),
            ),
          ),
        ]),
      );

  Widget _plusBanner(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PlusScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2B2A33), Color(0xFF47404F)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF7D774), size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(app.isPlus ? 'You are a Practo Plus member' : 'Get Practo Plus',
                      style: const TextStyle(
                          color: Color(0xFFF7D774),
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text(
                      app.isPlus
                          ? 'Unlimited free text chats are active'
                          : 'Unlimited free text chats · ${inr(kPlusPrice)}/year',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ]),
          ),
        ),
      );

  Widget _quickActions(BuildContext context) {
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final items = <(IconData, String, Color, VoidCallback)>[
      (Icons.videocam_rounded, 'Video\nConsult', kBlue, () {
        app.filters.reset();
        tabIndex.value = 1;
      }),
      (Icons.biotech_rounded, 'Lab\nTests', kGreen, () => tabIndex.value = 2),
      (Icons.medication_rounded, 'Medicines', const Color(0xFFEF6C57), () => tabIndex.value = 3),
      (Icons.folder_special_rounded, 'Health\nRecords', const Color(0xFF8E5CF7), () => tabIndex.value = 4),
      (Icons.alarm_rounded, 'Pill\nReminders', kAmber, () => push(const RemindersScreen())),
      (Icons.monitor_heart_rounded, 'Vitals\nTracker', kRed, () => push(const VitalsScreen())),
      (Icons.receipt_long_rounded, 'My\nPrescriptions', kCyan, () => push(const PrescriptionListScreen())),
      (Icons.chat_rounded, 'Chat with\nDoctor', const Color(0xFF2E9CCA), () => tabIndex.value = 1),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 6,
          mainAxisExtent: 92,
        ),
        children: [
          for (final it in items)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: it.$4,
              child: Column(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: it.$3.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(it.$1, color: it.$3, size: 25),
                ),
                const SizedBox(height: 4),
                Text(it.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _reminderPreview(BuildContext context) {
    final rows = <Widget>[];
    for (final r in app.reminders) {
      for (final t in r.times) {
        rows.add(ListTile(
          dense: true,
          leading: PillImage(r.shape, r.color, size: 40),
          title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(t.format(context)),
          trailing: Checkbox(
              value: app.isTaken(r, t),
              activeColor: kGreen,
              onChanged: (_) => app.toggleTaken(r, t)),
        ));
      }
    }
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              const Icon(Icons.check_circle_outline_rounded, color: kGreen),
              const SizedBox(width: 10),
              const Text('No medicines scheduled for today.',
                  style: TextStyle(color: kMuted)),
            ]),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(child: Column(children: rows.take(4).toList())),
    );
  }

  Widget _specialties(BuildContext context) {
    final icons = <String, IconData>{
      'General Physician': Icons.person_rounded,
      'Cardiologist': Icons.favorite_rounded,
      'Dermatologist': Icons.face_retouching_natural_rounded,
      'Pediatrician': Icons.child_care_rounded,
      'Gynecologist': Icons.pregnant_woman_rounded,
      'Orthopedic': Icons.accessibility_new_rounded,
      'ENT': Icons.hearing_rounded,
      'Psychiatrist': Icons.psychology_rounded,
      'Neurologist': Icons.memory_rounded,
      'Dentist': Icons.mood_rounded,
      'Diabetologist': Icons.bloodtype_rounded,
      'Ophthalmologist': Icons.visibility_rounded,
    };
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final s in specialties)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  app.filters
                    ..reset()
                    ..specialty = s;
                  app.refresh();
                  tabIndex.value = 1;
                },
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kBlue.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icons[s] ?? Icons.medical_services_rounded, color: kBlue, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(s,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _healthTips(BuildContext context) {
    final tips = [
      (Icons.water_drop_rounded, 'Stay Hydrated', 'Drink 8 glasses of water daily for better health.', kCyan),
      (Icons.directions_walk_rounded, 'Walk More', '30 minutes of walking reduces heart disease risk by 35%.', kGreen),
      (Icons.bedtime_rounded, 'Sleep Well', '7–9 hours of sleep boosts immunity and mental health.', kBlue),
      (Icons.no_food_rounded, 'Eat Mindfully', 'Reduce processed foods to lower inflammation.', const Color(0xFFEF6C57)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Health tips for you'),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tips.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final tip = tips[i];
              return Container(
                width: 200,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tip.$4.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tip.$4.withValues(alpha: .25)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(tip.$1, color: tip.$4, size: 24),
                  const SizedBox(height: 6),
                  Text(tip.$2,
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13, color: tip.$4)),
                  const SizedBox(height: 4),
                  Text(tip.$3,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: kMuted, height: 1.3)),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment a;
  const AppointmentCard(this.a, {super.key});
  @override
  Widget build(BuildContext context) {
    final up = a.status == 'Upcoming';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(children: [
            DoctorAvatar(a.doctor, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(a.doctor.specialty, style: const TextStyle(color: kMuted)),
                const SizedBox(height: 4),
                Text(fmtDateTime(a.time),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: kBlue)),
              ]),
            ),
            Tag(a.video ? 'Video' : 'Clinic',
                color: a.video ? kCyan : kGreen,
                icon: a.video ? Icons.videocam_rounded : Icons.local_hospital_rounded),
          ]),
          const SizedBox(height: 12),
          if (up)
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    app.cancel(a);
                    toast(context, 'Appointment cancelled');
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: a.video
                      ? () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => VideoConsultScreen(a)))
                      : () => toast(context, 'Visit ${a.doctor.clinic}, ${a.doctor.area}'),
                  icon: Icon(a.video ? Icons.videocam_rounded : Icons.directions_rounded),
                  label: Text(a.video ? 'Join video consult' : 'Get directions'),
                ),
              ),
            ])
          else
            Row(children: [
              Tag(a.status, color: a.status == 'Completed' ? kGreen : kRed),
              const Spacer(),
              if (a.rx != null)
                TextButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PrescriptionScreen(a.rx!))),
                  icon: const Icon(Icons.description_rounded, size: 18),
                  label: const Text('View prescription'),
                ),
            ]),
        ]),
      ),
    );
  }
}

/// Used by Doctors tab: "My appointments" sheet.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My appointments')),
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => app.appointments.isEmpty
              ? const EmptyState(Icons.event_busy_rounded, 'No appointments', 'Book a doctor to get started.')
              : ListView(padding: const EdgeInsets.all(16), children: [
                  for (final a in app.appointments)
                    Padding(padding: const EdgeInsets.only(bottom: 10), child: AppointmentCard(a)),
                ]),
        ),
      );
}
