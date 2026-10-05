import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class PrescriptionScreen extends StatelessWidget {
  final Prescription rx;
  final bool justIssued;
  const PrescriptionScreen(this.rx, {super.key, this.justIssued = false});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Prescription')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: rx.asText()));
                    if (context.mounted) toast(context, 'Prescription copied — paste it in any app to share');
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    app.addRecord('Prescription_${rx.doctor.name.replaceAll(' ', '_')}_${rx.id}.pdf', 'Prescriptions', 190);
                    toast(context, 'Saved to Health Records › Prescriptions');
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                ),
              ),
            ]),
          ),
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          if (justIssued)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kGreen.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.check_circle_rounded, color: kGreen),
                SizedBox(width: 10),
                Expanded(child: Text('Consultation complete. Your doctor has shared this prescription.')),
              ]),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  DoctorAvatar(rx.doctor, size: 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(rx.doctor.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(rx.doctor.qualifications, style: const TextStyle(color: kMuted, fontSize: 12.5)),
                      Text('${rx.doctor.clinic}, ${rx.doctor.city}', style: const TextStyle(color: kMuted, fontSize: 12.5)),
                    ]),
                  ),
                ]),
                const Divider(height: 26),
                Row(children: [
                  Expanded(child: _kv('Patient', app.userName)),
                  Expanded(child: _kv('Date', fmtDateLong(rx.date))),
                  Expanded(child: _kv('Rx No.', rx.id)),
                ]),
                const SizedBox(height: 14),
                _kv('Diagnosis', rx.diagnosis),
                const SizedBox(height: 16),
                const Text('℞', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kBlue)),
                for (var i = 0; i < rx.items.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CircleAvatar(radius: 12, backgroundColor: kBlue, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.white))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(rx.items[i].name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${rx.items[i].dosage} · ${rx.items[i].duration}', style: const TextStyle(color: kMuted)),
                          Text(rx.items[i].instructions, style: const TextStyle(color: kMuted, fontSize: 12.5)),
                        ]),
                      ),
                    ]),
                  ),
                const Divider(height: 26),
                _kv('Advice', rx.advice),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              for (final it in rx.items) {
                final m = medicines.where((m) => it.name.startsWith(m.name.split(' ').first));
                if (m.isNotEmpty) app.addToCart(m.first);
              }
              toast(context, 'Matching medicines added to your cart');
              tabIndex.value = 3;
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            icon: const Icon(Icons.medication_rounded),
            label: const Text('Order these medicines'),
          ),
        ]),
      );

  Widget _kv(String k, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: const TextStyle(color: kMuted, fontSize: 12)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]);
}

class PrescriptionListScreen extends StatelessWidget {
  const PrescriptionListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My prescriptions')),
        body: ListenableBuilder(
          listenable: app,
          builder: (context, _) => app.prescriptions.isEmpty
              ? const EmptyState(Icons.description_outlined, 'No prescriptions yet', 'Prescriptions from your consultations appear here.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: app.prescriptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = app.prescriptions[i];
                    return Card(
                      child: ListTile(
                        leading: DoctorAvatar(r.doctor, size: 44),
                        title: Text(r.diagnosis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${r.doctor.name} · ${fmtDateLong(r.date)}\n${r.items.length} medicines'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionScreen(r))),
                      ),
                    );
                  },
                ),
        ),
      );
}
