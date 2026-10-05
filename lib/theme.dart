import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kBlue = Color(0xFF28328C);
const kCyan = Color(0xFF14BEF0);
const kGreen = Color(0xFF1FA67A);
const kRed = Color(0xFFE5484D);
const kAmber = Color(0xFFF5A623);
const kBg = Color(0xFFF4F6FB);
const kBorder = Color(0xFFE4E8F2);
const kMuted = Color(0xFF6B7491);
const kGold = Color(0xFFC8921A);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kBlue,
    primary: kBlue,
    secondary: kCyan,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: kBlue,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kBlue),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kBorder),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: kCyan.withValues(alpha: .18),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kBlue,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kBlue,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: kBlue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBorder),
      ),
    ),
  );
}

String inr(num v) => '₹${NumberFormat.decimalPattern('en_IN').format(v.round())}';
String fmtDate(DateTime d) => DateFormat('EEE, d MMM').format(d);
String fmtDateLong(DateTime d) => DateFormat('d MMM yyyy').format(d);
String fmtTime(DateTime d) => DateFormat('h:mm a').format(d);
String fmtDateTime(DateTime d) => '${fmtDate(d)} · ${fmtTime(d)}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
