import 'dart:async';
import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'plus.dart';
import 'prescription.dart';

/// Text chat with a doctor. Free with Practo Plus, otherwise a one-time fee per doctor.
class ChatScreen extends StatelessWidget {
  final Doctor d;
  const ChatScreen(this.d, {super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(children: [
              DoctorAvatar(d, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const Text('Online', style: TextStyle(fontSize: 12, color: kGreen)),
                ]),
              ),
              if (app.isPlus) const Padding(padding: EdgeInsets.only(right: 12), child: PlusBadge()),
            ]),
          ),
          body: app.chatFree(d)
              ? ChatPanel(d)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.chat_rounded, size: 60, color: kCyan),
                      const SizedBox(height: 12),
                      Text('Chat with ${d.name}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Text chat costs ${inr(kTextChatFee)} per doctor, or is unlimited and free with Practo Plus.',
                          textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => app.unlockChat(d),
                        child: Text('Pay ${inr(kTextChatFee)} & start chat'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const PlusScreen())),
                        icon: const Icon(Icons.workspace_premium_rounded),
                        label: Text('Get Plus ${inr(kPlusPrice)}/yr – unlimited chats'),
                      ),
                    ]),
                  ),
                ),
        ),
      );
}

class ChatPanel extends StatefulWidget {
  final Doctor d;
  final bool dark;
  const ChatPanel(this.d, {super.key, this.dark = false});
  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final ctrl = TextEditingController();
  final scroll = ScrollController();

  void send() {
    final t = ctrl.text.trim();
    if (t.isEmpty) return;
    ctrl.clear();
    app.sendChat(widget.d, t);
    Future.delayed(const Duration(milliseconds: 100), _down);
  }

  void _down() {
    if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent + 80, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final msgs = app.chatFor(widget.d);
          WidgetsBinding.instance.addPostFrameCallback((_) => _down());
          return Column(children: [
            Expanded(
              child: ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.all(14),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  return Align(
                    alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
                      decoration: BoxDecoration(
                        color: m.mine ? kBlue : (widget.dark ? Colors.white12 : Colors.white),
                        border: m.mine || widget.dark ? null : Border.all(color: kBorder),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(m.mine ? 16 : 4),
                          bottomRight: Radius.circular(m.mine ? 4 : 16),
                        ),
                      ),
                      child: Text(m.text,
                          style: TextStyle(color: m.mine || widget.dark ? Colors.white : null)),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      onSubmitted: (_) => send(),
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(hintText: 'Type a message', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: kBlue),
                    onPressed: send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ]),
              ),
            ),
          ]);
        },
      );
}

/// Simulated HD video call UI (no camera/network): timer, controls, in-call chat.
class VideoConsultScreen extends StatefulWidget {
  final Appointment appt;
  const VideoConsultScreen(this.appt, {super.key});
  @override
  State<VideoConsultScreen> createState() => _VideoConsultScreenState();
}

class _VideoConsultScreenState extends State<VideoConsultScreen> with SingleTickerProviderStateMixin {
  late final Timer timer;
  late final AnimationController pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  int secs = 0;
  bool mic = true, cam = true, chat = false;
  String quality = 'HD 1080p';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => secs++));
  }

  @override
  void dispose() {
    timer.cancel();
    pulse.dispose();
    super.dispose();
  }

  String get clock =>
      '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';

  void _end() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('End consultation?'),
        content: const Text('The doctor will share your prescription after the call ends.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('End call')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final rx = app.complete(widget.appt);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PrescriptionScreen(rx, justIssued: true)));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.appt.doctor;
    return Scaffold(
      backgroundColor: const Color(0xFF0E1229),
      body: SafeArea(
        child: Stack(children: [
          // Remote video (simulated)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF1A2160), Color(0xFF0E1229)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (_, _) => Container(
                    padding: EdgeInsets.all(14 + pulse.value * 10),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: kCyan.withValues(alpha: .12)),
                    child: DoctorAvatar(d, size: 130),
                  ),
                ),
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.circle, size: 9, color: kRed),
                  const SizedBox(width: 6),
                  Text(clock, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (v) => setState(() => quality = v),
                itemBuilder: (_) => [for (final q in const ['HD 1080p', 'HD 720p', 'SD 480p', 'Auto']) PopupMenuItem(value: q, child: Text(q))],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.hd_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(quality, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
              ),
              const Spacer(),
              const Icon(Icons.signal_cellular_alt_rounded, color: Colors.white70),
            ]),
          ),
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: Column(children: [
              Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              Text(d.specialty, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          // Self view
          Positioned(
            right: 14,
            top: 120,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3070),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: cam
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.person_rounded, size: 44, color: Colors.white54),
                        Text('You', style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 12)),
                      ])
                    : const Icon(Icons.videocam_off_rounded, color: Colors.white54),
              ),
            ),
          ),
          // Chat panel
          if (chat)
            Positioned(
              left: 0,
              right: 0,
              bottom: 96,
              height: 300,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: .6), borderRadius: BorderRadius.circular(18)),
                child: ChatPanel(d, dark: true),
              ),
            ),
          // Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ctl(mic ? Icons.mic_rounded : Icons.mic_off_rounded, mic, () => setState(() => mic = !mic)),
              _ctl(cam ? Icons.videocam_rounded : Icons.videocam_off_rounded, cam, () => setState(() => cam = !cam)),
              _ctl(Icons.chat_rounded, chat, () => setState(() => chat = !chat)),
              _ctl(Icons.call_end_rounded, false, _end, red: true),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _ctl(IconData i, bool on, VoidCallback f, {bool red = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        child: InkResponse(
          onTap: f,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: red ? kRed : (on ? Colors.white24 : Colors.white),
            ),
            child: Icon(i, color: red ? Colors.white : (on ? Colors.white : Colors.black87)),
          ),
        ),
      );
}
