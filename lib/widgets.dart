import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'art.dart';
import 'data.dart';
import 'theme.dart';

void toast(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1B1F3B)))),
          ?trailing,
        ]),
      );
}

class DoctorAvatar extends StatelessWidget {
  final Doctor doctor;
  final double size;
  const DoctorAvatar(this.doctor, {super.key, this.size = 60});
  @override
  Widget build(BuildContext context) => DoctorPhoto(doctor, size: size);
}

class RatingChip extends StatelessWidget {
  final double rating;
  const RatingChip(this.rating, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration:
            BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.thumb_up_alt_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text('${(rating * 20).round()}%',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Tag(this.text, {super.key, this.color = kBlue, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) Icon(icon, size: 12, color: color),
          if (icon != null) const SizedBox(width: 4),
          Text(text,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ]),
      );
}

class PlusBadge extends StatelessWidget {
  const PlusBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF7D774), Color(0xFFC8921A)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFF4A3300)),
          SizedBox(width: 3),
          Text('PLUS',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF4A3300))),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const EmptyState(this.icon, this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: kBorder),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
          ]),
        ),
      );
}

/// Vertical stage tracker used by lab sample collection and medicine delivery.
class StageTracker extends StatelessWidget {
  final List<String> stages;
  final int current;
  const StageTracker({super.key, required this.stages, required this.current});
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < stages.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 28,
                child: Column(children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= current ? kGreen : Colors.white,
                      border: Border.all(color: i <= current ? kGreen : kBorder, width: 2),
                    ),
                    child: i <= current
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                  if (i < stages.length - 1)
                    Expanded(
                        child: Container(width: 2, color: i < current ? kGreen : kBorder)),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14, left: 4),
                  child: Text(stages[i],
                      style: TextStyle(
                          fontWeight: i == current ? FontWeight.w800 : FontWeight.w500,
                          color: i <= current ? const Color(0xFF1B1F3B) : kMuted)),
                ),
              ),
            ]),
          ),
      ]);
}

/// Horizontal bar with the normal range highlighted and a marker for the value.
class RangeBar extends StatelessWidget {
  final double min, max, value;
  const RangeBar({super.key, required this.min, required this.max, required this.value});
  @override
  Widget build(BuildContext context) {
    final span = max - min;
    final lo = min - span * .6, hi = max + span * .6;
    double pos(double v) => ((v - lo) / (hi - lo)).clamp(0.0, 1.0);
    final status = value < min ? 'Low' : (value > max ? 'High' : 'Normal');
    final color = status == 'Normal' ? kGreen : (status == 'High' ? kRed : kAmber);
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return SizedBox(
        height: 22,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
              top: 9,
              left: 0,
              right: 0,
              child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEDEFF6), borderRadius: BorderRadius.circular(3)))),
          Positioned(
              top: 9,
              left: w * pos(min),
              width: w * (pos(max) - pos(min)),
              child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                      color: kGreen.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(3)))),
          Positioned(
              top: 3,
              left: w * pos(value) - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black26)]),
              )),
        ]),
      );
    });
  }
}

/// Draws a pill (round tablet, capsule or oval tablet) so reminders show a "pill image".
class PillImage extends StatelessWidget {
  final PillShape shape;
  final Color color;
  final double size;
  const PillImage(this.shape, this.color, {super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: kCyan.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(painter: _PillPainter(shape, color)),
      );
}

class _PillPainter extends CustomPainter {
  final PillShape shape;
  final Color color;
  _PillPainter(this.shape, this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final u = s.width;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final shine = Paint()..color = Colors.white.withValues(alpha: .6);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    switch (shape) {
      case PillShape.round:
        canvas.drawCircle(Offset.zero, u * .28, fill);
        canvas.drawCircle(Offset.zero, u * .28, line);
        canvas.drawLine(Offset(-u * .28, 0), Offset(u * .28, 0), line);
        canvas.drawCircle(Offset(-u * .1, -u * .12), u * .05, shine);
      case PillShape.oval:
        canvas.rotate(-math.pi / 6);
        final r = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: u * .62, height: u * .32),
            Radius.circular(u * .16));
        canvas.drawRRect(r, fill);
        canvas.drawRRect(r, line);
        canvas.drawLine(Offset(0, -u * .16), Offset(0, u * .16), line);
      case PillShape.capsule:
        canvas.rotate(-math.pi / 4);
        final w = u * .66, h = u * .28;
        final left = RRect.fromRectAndCorners(
            Rect.fromLTWH(-w / 2, -h / 2, w / 2, h),
            topLeft: Radius.circular(h / 2),
            bottomLeft: Radius.circular(h / 2));
        final right = RRect.fromRectAndCorners(Rect.fromLTWH(0, -h / 2, w / 2, h),
            topRight: Radius.circular(h / 2), bottomRight: Radius.circular(h / 2));
        canvas.drawRRect(left, fill);
        canvas.drawRRect(right, Paint()..color = Colors.white);
        canvas.drawRRect(left, line);
        canvas.drawRRect(right, line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PillPainter o) => o.shape != shape || o.color != color;
}
