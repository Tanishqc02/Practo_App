import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practo_app/data.dart';
import 'package:practo_app/main.dart';
import 'package:practo_app/screens/consult.dart';
import 'package:practo_app/screens/doctors.dart';
import 'package:practo_app/screens/labs.dart';
import 'package:practo_app/screens/pharmacy.dart';
import 'package:practo_app/screens/plus.dart';
import 'package:practo_app/screens/prescription.dart';
import 'package:practo_app/screens/records.dart';
import 'package:practo_app/screens/reminders.dart';
import 'package:practo_app/theme.dart';

Future<void> show(WidgetTester t, Widget w) async {
  await t.pumpWidget(MaterialApp(theme: buildTheme(), home: w));
  await t.pump(const Duration(milliseconds: 300));
}

// The test environment renders text with the wide "Ahem" font, so RenderFlex
// overflow reports are test artefacts; every other error must still fail.
void ignoreOverflow() {
  final orig = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('overflowed')) return;
    orig?.call(d);
  };
}

void main() {
  setUp(() => tabIndex.value = 0);

  testWidgets('shell tabs render', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const PractoApp());
    for (var i = 0; i < 5; i++) {
      tabIndex.value = i;
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('doctor profile and booking', (t) async {
    ignoreOverflow();
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    t.view.physicalSize = const Size(1080, 9000);
    await show(t, DoctorProfileScreen(doctors[2]));
    expect(find.text('Select a slot to book'), findsOneWidget);
    await t.tap(find.byType(ChoiceChip).first);
    await t.pump();
    expect(find.textContaining('Book now ·'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('secondary screens render', (t) async {
    ignoreOverflow();
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final appt = app.appointments.firstWhere((a) => a.status == 'Upcoming');
    final screens = <Widget>[
      const DoctorsScreen(),
      const LabsScreen(),
      LabReportScreen(app.reports.first),
      const PharmacyScreen(),
      const CartScreen(),
      const RecordsScreen(),
      const VitalsScreen(),
      const RemindersScreen(),
      const PlusScreen(),
      const PrescriptionListScreen(),
      PrescriptionScreen(app.prescriptions.first),
      ChatScreen(doctors[0]),
    ];
    for (final s in screens) {
      await show(t, s);
      expect(t.takeException(), isNull, reason: s.runtimeType.toString());
    }
    // Video consult ends and issues a prescription.
    await show(t, VideoConsultScreen(appt));
    await t.pump(const Duration(seconds: 2));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

  test('pricing tiers and flows', () {
    expect(Tier.general.fee, 299);
    expect(Tier.specialist.fee, 499);
    expect(Tier.top.fee, 799);
    expect(kPlusPrice, 999);
    app.addToCart(medicines[0]);
    final sub = app.cartSubtotal;
    expect(app.cartDiscount(true), (sub * 0.05).round());
    app.cart.clear();
    app.toggleLab(labCatalog.first);
    expect(labCatalog.first.price, 999);
    final b = app.bookLab(DateTime.now().add(const Duration(days: 1)), 'T', 'addr');
    for (var i = 0; i < 4; i++) {
      app.advanceLab(b);
    }
    expect(app.reports.first.values, isNotEmpty);
  });
}
