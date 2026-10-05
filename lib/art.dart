import 'package:flutter/material.dart';
import 'data.dart';
import 'theme.dart';

const _femaleIds = {2, 4, 5, 7, 9, 11, 13, 15};
const _skin = [Color(0xFFF1C9A5), Color(0xFFE0AC84), Color(0xFFC68B63), Color(0xFFA96E4A)];
const _hair = [Color(0xFF1E1B1A), Color(0xFF3B2A20), Color(0xFF5A3B2A), Color(0xFF2B2B33)];
const _bg = [
  [Color(0xFFD7E3FF), Color(0xFF9FB8F5)],
  [Color(0xFFCFF3FA), Color(0xFF8ED8EE)],
  [Color(0xFFD6F5E8), Color(0xFF8BDDBC)],
  [Color(0xFFE9DEFF), Color(0xFFBFA6F5)],
  [Color(0xFFFFE1D8), Color(0xFFF7B3A0)],
];

/// Illustrated doctor portrait (drawn in code so it works offline and needs no image files).
class DoctorPortrait extends CustomPainter {
  final int id;
  DoctorPortrait(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final female = _femaleIds.contains(id);
    final skin = Paint()..color = _skin[id % _skin.length];
    final hair = Paint()..color = _hair[(id * 3) % _hair.length];
    final bg = _bg[id % _bg.length];
    Offset p(double x, double y) => Offset(x * s, y * s);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(colors: bg, begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(Offset.zero & size),
    );
    // Long hair behind the head for female doctors.
    if (female) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(.27 * s, .24 * s, .73 * s, .74 * s), Radius.circular(.2 * s)), hair);
    }
    // Coat + scrubs.
    canvas.drawOval(Rect.fromCenter(center: p(.5, 1.02), width: .96 * s, height: .56 * s), Paint()..color = Colors.white);
    final v = Path()
      ..moveTo(.37 * s, .73 * s)
      ..lineTo(.63 * s, .73 * s)
      ..lineTo(.5 * s, .95 * s)
      ..close();
    canvas.drawPath(v, Paint()..color = kCyan);
    // Neck + head.
    canvas.drawRect(Rect.fromLTWH(.45 * s, .56 * s, .1 * s, .2 * s), skin);
    if (!female) canvas.drawCircle(p(.5, .39), .205 * s, hair);
    canvas.drawOval(Rect.fromCenter(center: p(.5, .43), width: .36 * s, height: .4 * s), skin);
    // Fringe.
    canvas.drawArc(Rect.fromCenter(center: p(.5, .3), width: .4 * s, height: .2 * s), 3.14, 3.14, true, hair);
    // Face.
    final dark = Paint()..color = const Color(0xFF2A2A33);
    canvas.drawCircle(p(.43, .45), .018 * s, dark);
    canvas.drawCircle(p(.57, .45), .018 * s, dark);
    canvas.drawArc(Rect.fromCenter(center: p(.5, .51), width: .13 * s, height: .08 * s), .2, 2.7, false,
        Paint()
          ..color = const Color(0xFF8A4B3C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .012 * s
          ..strokeCap = StrokeCap.round);
    // Stethoscope.
    final steth = Paint()
      ..color = const Color(0xFF4A4F63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .016 * s
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(.4 * s, .74 * s)
      ..quadraticBezierTo(.36 * s, .98 * s, .55 * s, .96 * s)
      ..moveTo(.6 * s, .74 * s)
      ..quadraticBezierTo(.64 * s, .98 * s, .55 * s, .96 * s);
    canvas.drawPath(path, steth);
    canvas.drawCircle(p(.55, .96), .028 * s, Paint()..color = const Color(0xFF9AA0B5));
  }

  @override
  bool shouldRepaint(DoctorPortrait old) => old.id != id;
}

/// Doctor photo: uses `assets/doctors/doctor_<id>.jpg` when you add one, otherwise the illustration.
class DoctorPhoto extends StatelessWidget {
  final Doctor doctor;
  final double size;
  const DoctorPhoto(this.doctor, {super.key, this.size = 60});
  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/doctors/doctor_${doctor.id}.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => CustomPaint(painter: DoctorPortrait(doctor.id)),
          ),
        ),
      );
}

/// Row of lab test tubes for the lab banner.
class TestTubesArt extends StatelessWidget {
  final double height;
  const TestTubesArt({super.key, this.height = 80});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: height * 1.1, height: height, child: CustomPaint(painter: _TubesPainter()));
}

class _TubesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [const Color(0xFFFF6B6B), const Color(0xFFFFD166), const Color(0xFF4ECDC4)];
    final fills = [.65, .5, .78];
    final w = size.width / 4;
    for (var i = 0; i < 3; i++) {
      final x = w * (i + .5) + i * w * .12;
      final tube = RRect.fromRectAndCorners(Rect.fromLTWH(x, size.height * .1, w * .85, size.height * .85),
          bottomLeft: Radius.circular(w), bottomRight: Radius.circular(w), topLeft: const Radius.circular(4), topRight: const Radius.circular(4));
      canvas.drawRRect(tube, Paint()..color = Colors.white.withValues(alpha: .35));
      canvas.save();
      canvas.clipRRect(tube);
      canvas.drawRect(Rect.fromLTWH(x, size.height * (1 - fills[i]), w, size.height), Paint()..color = colors[i]);
      canvas.restore();
      canvas.drawRRect(tube, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, size.height * .06, w * .85 + 6, 7), const Radius.circular(3)),
          Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
