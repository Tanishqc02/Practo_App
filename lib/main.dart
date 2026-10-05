import 'package:flutter/material.dart';
import 'data.dart';
import 'screens/doctors.dart';
import 'screens/home.dart';
import 'screens/labs.dart';
import 'screens/pharmacy.dart';
import 'screens/records.dart';
import 'theme.dart';

void main() => runApp(const PractoApp());

class PractoApp extends StatelessWidget {
  const PractoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Practo',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFE9ECF5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: child,
            ),
          ),
        ),
        home: const Shell(),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tabIndex,
        builder: (context, i, _) => Scaffold(
          body: IndexedStack(index: i, children: const [
            HomeScreen(),
            DoctorsScreen(),
            LabsScreen(),
            PharmacyScreen(),
            RecordsScreen(),
          ]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            onDestinationSelected: (v) => tabIndex.value = v,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services_rounded), label: 'Doctors'),
              NavigationDestination(icon: Icon(Icons.biotech_outlined), selectedIcon: Icon(Icons.biotech_rounded), label: 'Lab Tests'),
              NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication_rounded), label: 'Medicines'),
              NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'Records'),
            ],
          ),
        ),
      );
}
