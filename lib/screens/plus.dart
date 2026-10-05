import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Practo Plus')),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: app.isPlus
                  ? const FilledButton(onPressed: null, child: Text('You are subscribed'))
                  : FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: kGold),
                      onPressed: () {
                        app.subscribePlus();
                        toast(context, 'Welcome to Practo Plus!');
                      },
                      child: Text('Subscribe for ${inr(kPlusPrice)} / year'),
                    ),
            ),
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2B2A33), Color(0xFF55485F)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                const Icon(Icons.workspace_premium_rounded, size: 56, color: Color(0xFFF7D774)),
                const SizedBox(height: 8),
                const Text('Practo Plus',
                    style: TextStyle(color: Color(0xFFF7D774), fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(app.isPlus ? 'Active until ${fmtDateLong(app.plusUntil!)}' : '${inr(kPlusPrice)} per year',
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
                if (app.isPlus) ...[const SizedBox(height: 10), const PlusBadge()],
              ]),
            ),
            const SectionTitle('Member benefits'),
            for (final b in const [
              (Icons.chat_rounded, 'Unlimited free text chats', 'Chat with any doctor, any number of times – no per-chat fee.'),
              (Icons.bolt_rounded, 'Priority responses', 'Plus members are moved to the front of the doctor\'s chat queue.'),
              (Icons.folder_special_rounded, 'Health record vault', 'Securely store reports, prescriptions and vitals history.'),
              (Icons.workspace_premium_rounded, 'Plus badge', 'A gold badge on your profile and chats.'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: kGold.withValues(alpha: .15), child: Icon(b.$1, color: kGold)),
                    title: Text(b.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(b.$3),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                    'Without Plus, a text chat costs ${inr(kTextChatFee)} per doctor. Break even after ${(kPlusPrice / kTextChatFee).ceil()} chats.',
                    style: const TextStyle(color: kMuted)),
              ),
            ),
            const SizedBox(height: 4),
            const Center(child: Text('Demo checkout — no real payment is taken.', style: TextStyle(color: kMuted, fontSize: 12))),
          ]),
        ),
      );
}
