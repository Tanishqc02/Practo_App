import 'package:flutter/material.dart';

// ───────────────────────── Pricing constants ─────────────────────────
const int kPlusPrice = 999; // per year
const int kTextChatFee = 99; // per chat session for non-Plus users
const double kRefillDiscount = 0.05;

// ───────────────────────── Doctors ─────────────────────────
enum Tier { general, specialist, top }

extension TierX on Tier {
  String get label => switch (this) {
        Tier.general => 'General Physician',
        Tier.specialist => 'Specialist',
        Tier.top => 'Top Doctor',
      };
  int get fee => switch (this) {
        Tier.general => 299,
        Tier.specialist => 499,
        Tier.top => 799,
      };
}

class Review {
  final String name, text, date;
  final int rating;
  const Review(this.name, this.rating, this.text, this.date);
}

class Doctor {
  final int id;
  final String name, specialty, qualifications, clinic, area, city, languages;
  final Tier tier;
  final int experience, ratings;
  final double rating;
  final List<Review> reviews;
  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.tier,
    required this.qualifications,
    required this.experience,
    required this.rating,
    required this.ratings,
    required this.clinic,
    required this.area,
    required this.city,
    required this.languages,
    required this.reviews,
  });
  int get fee => tier.fee;
  String get initials => name
      .replaceAll('Dr. ', '')
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => e[0])
      .take(2)
      .join();
}

const _reviews = [
  Review('Rohit S.', 5, 'Very patient and explained everything clearly. Felt much better within days.', '2 weeks ago'),
  Review('Ananya P.', 5, 'Excellent diagnosis and no unnecessary tests. Clinic was clean and on time.', '1 month ago'),
  Review('Imran K.', 4, 'Good doctor, a little wait at the clinic but worth it.', '1 month ago'),
  Review('Meera D.', 5, 'The video consultation was smooth and the prescription arrived instantly.', '2 months ago'),
  Review('Vikas T.', 4, 'Friendly and knowledgeable. Follow-up chat was helpful.', '3 months ago'),
];

List<Review> _rv(int seed) =>
    List.generate(4, (i) => _reviews[(seed + i) % _reviews.length]);

const specialties = [
  'General Physician',
  'Cardiologist',
  'Dermatologist',
  'Pediatrician',
  'Gynecologist',
  'Orthopedic',
  'ENT',
  'Psychiatrist',
  'Neurologist',
  'Dentist',
  'Diabetologist',
  'Ophthalmologist',
];

const cities = ['Bengaluru', 'Delhi', 'Mumbai', 'Hyderabad', 'Chennai', 'Pune'];

final doctors = <Doctor>[
  Doctor(id: 1, name: 'Dr. Aarav Mehta', specialty: 'General Physician', tier: Tier.general, qualifications: 'MBBS, MD (General Medicine)', experience: 12, rating: 4.6, ratings: 1840, clinic: 'CarePlus Clinic', area: 'Indiranagar', city: 'Bengaluru', languages: 'English, Hindi, Kannada', reviews: _rv(0)),
  Doctor(id: 2, name: 'Dr. Priya Nair', specialty: 'Dermatologist', tier: Tier.specialist, qualifications: 'MBBS, MD (Dermatology), FAAD', experience: 9, rating: 4.8, ratings: 960, clinic: 'Glow Skin Institute', area: 'Koramangala', city: 'Bengaluru', languages: 'English, Malayalam, Hindi', reviews: _rv(1)),
  Doctor(id: 3, name: 'Dr. Rajesh Khanna', specialty: 'Cardiologist', tier: Tier.top, qualifications: 'MBBS, MD, DM (Cardiology), FACC', experience: 26, rating: 4.9, ratings: 3120, clinic: 'Apollo Heart Centre', area: 'Jayanagar', city: 'Bengaluru', languages: 'English, Hindi, Punjabi', reviews: _rv(2)),
  Doctor(id: 4, name: 'Dr. Sneha Kulkarni', specialty: 'Pediatrician', tier: Tier.specialist, qualifications: 'MBBS, DCH, MD (Pediatrics)', experience: 14, rating: 4.7, ratings: 2210, clinic: 'Little Steps Hospital', area: 'Kothrud', city: 'Pune', languages: 'English, Marathi, Hindi', reviews: _rv(3)),
  Doctor(id: 5, name: 'Dr. Farah Siddiqui', specialty: 'Gynecologist', tier: Tier.top, qualifications: 'MBBS, MS (OBG), FRCOG', experience: 22, rating: 4.9, ratings: 2740, clinic: 'Motherhood Hospital', area: 'Bandra West', city: 'Mumbai', languages: 'English, Hindi, Urdu', reviews: _rv(4)),
  Doctor(id: 6, name: 'Dr. Vikram Reddy', specialty: 'Orthopedic', tier: Tier.specialist, qualifications: 'MBBS, MS (Ortho), Fellowship Joint Replacement', experience: 17, rating: 4.5, ratings: 1330, clinic: 'BoneCare Ortho Clinic', area: 'Banjara Hills', city: 'Hyderabad', languages: 'English, Telugu, Hindi', reviews: _rv(0)),
  Doctor(id: 7, name: 'Dr. Kavita Sharma', specialty: 'General Physician', tier: Tier.general, qualifications: 'MBBS, DNB (Family Medicine)', experience: 8, rating: 4.4, ratings: 780, clinic: 'Sharma Family Clinic', area: 'Saket', city: 'Delhi', languages: 'English, Hindi', reviews: _rv(2)),
  Doctor(id: 8, name: 'Dr. Arjun Menon', specialty: 'Psychiatrist', tier: Tier.specialist, qualifications: 'MBBS, MD (Psychiatry)', experience: 11, rating: 4.7, ratings: 890, clinic: 'MindWell Centre', area: 'Adyar', city: 'Chennai', languages: 'English, Tamil, Malayalam', reviews: _rv(1)),
  Doctor(id: 9, name: 'Dr. Neha Bansal', specialty: 'Dentist', tier: Tier.general, qualifications: 'BDS, MDS (Orthodontics)', experience: 10, rating: 4.6, ratings: 1560, clinic: 'Smile Dental Studio', area: 'HSR Layout', city: 'Bengaluru', languages: 'English, Hindi', reviews: _rv(3)),
  Doctor(id: 10, name: 'Dr. Sanjay Iyer', specialty: 'Neurologist', tier: Tier.top, qualifications: 'MBBS, MD, DM (Neurology)', experience: 24, rating: 4.8, ratings: 1980, clinic: 'Fortis Neuro Institute', area: 'Vasant Kunj', city: 'Delhi', languages: 'English, Hindi, Tamil', reviews: _rv(4)),
  Doctor(id: 11, name: 'Dr. Lakshmi Rao', specialty: 'Diabetologist', tier: Tier.specialist, qualifications: 'MBBS, MD, Diploma in Diabetology', experience: 15, rating: 4.6, ratings: 1120, clinic: 'Sugar & Wellness Clinic', area: 'Madhapur', city: 'Hyderabad', languages: 'English, Telugu', reviews: _rv(0)),
  Doctor(id: 12, name: 'Dr. Manish Joshi', specialty: 'ENT', tier: Tier.specialist, qualifications: 'MBBS, MS (ENT)', experience: 13, rating: 4.5, ratings: 870, clinic: 'ClearHear ENT Centre', area: 'Andheri East', city: 'Mumbai', languages: 'English, Hindi, Marathi', reviews: _rv(2)),
  Doctor(id: 13, name: 'Dr. Tanvi Desai', specialty: 'Ophthalmologist', tier: Tier.top, qualifications: 'MBBS, MS (Ophthal), FRCS', experience: 19, rating: 4.9, ratings: 2050, clinic: 'Vision Plus Eye Hospital', area: 'Koregaon Park', city: 'Pune', languages: 'English, Hindi, Gujarati', reviews: _rv(1)),
  Doctor(id: 14, name: 'Dr. Suresh Babu', specialty: 'General Physician', tier: Tier.general, qualifications: 'MBBS, MD (General Medicine)', experience: 18, rating: 4.7, ratings: 2400, clinic: 'Anna Nagar Clinic', area: 'Anna Nagar', city: 'Chennai', languages: 'English, Tamil', reviews: _rv(3)),
  Doctor(id: 15, name: 'Dr. Ritu Agarwal', specialty: 'Dermatologist', tier: Tier.top, qualifications: 'MBBS, MD (Derm), Fellowship Cosmetology', experience: 20, rating: 4.8, ratings: 2600, clinic: 'Skin & Soul Clinic', area: 'Juhu', city: 'Mumbai', languages: 'English, Hindi', reviews: _rv(4)),
];

List<DateTime> slotsFor(Doctor d, DateTime day) {
  if ((d.id + day.weekday) % 7 == 0) return []; // weekly off
  final out = <DateTime>[];
  var i = 0;
  for (var h = 9; h < 20; h++) {
    for (final m in [0, 30]) {
      i++;
      if ((d.id * 7 + day.day * 3 + i) % 3 == 0) continue;
      out.add(DateTime(day.year, day.month, day.day, h, m));
    }
  }
  return out;
}

// ───────────────────────── Appointments & prescriptions ─────────────────────────
class RxItem {
  final String name, dosage, duration, instructions;
  const RxItem(this.name, this.dosage, this.duration, this.instructions);
}

class Prescription {
  final String id, diagnosis, advice;
  final Doctor doctor;
  final DateTime date;
  final List<RxItem> items;
  Prescription(this.id, this.doctor, this.date, this.diagnosis, this.items, this.advice);

  String asText() {
    final b = StringBuffer()
      ..writeln('PRESCRIPTION  #$id')
      ..writeln('${doctor.name} (${doctor.specialty})')
      ..writeln(doctor.qualifications)
      ..writeln('Date: ${date.day}/${date.month}/${date.year}')
      ..writeln('Diagnosis: $diagnosis')
      ..writeln();
    for (var i = 0; i < items.length; i++) {
      final r = items[i];
      b.writeln('${i + 1}. ${r.name} — ${r.dosage} for ${r.duration} (${r.instructions})');
    }
    b..writeln()..writeln('Advice: $advice');
    return b.toString();
  }
}

class Appointment {
  final String id;
  final Doctor doctor;
  final DateTime time;
  final bool video;
  final int fee;
  String status; // Upcoming, Completed, Cancelled
  Prescription? rx;
  Appointment(this.id, this.doctor, this.time, this.video, this.fee,
      {this.status = 'Upcoming', this.rx});
}

class ChatMsg {
  final String text;
  final bool mine;
  final DateTime at;
  ChatMsg(this.text, this.mine) : at = DateTime.now();
}

// ───────────────────────── Labs ─────────────────────────
class LabParam {
  final String name, unit;
  final double min, max;
  const LabParam(this.name, this.unit, this.min, this.max);
}

class LabTest {
  final String id, name, desc;
  final int price, tests;
  final bool isPackage, fasting;
  final List<LabParam> params;
  const LabTest(this.id, this.name, this.desc, this.price, this.tests, this.params,
      {this.isPackage = false, this.fasting = false});
}

const _cbc = [
  LabParam('Hemoglobin', 'g/dL', 13, 17),
  LabParam('WBC Count', '10³/µL', 4, 11),
  LabParam('Platelets', '10³/µL', 150, 410),
];
const _lipid = [
  LabParam('Total Cholesterol', 'mg/dL', 0, 200),
  LabParam('LDL', 'mg/dL', 0, 100),
  LabParam('HDL', 'mg/dL', 40, 80),
  LabParam('Triglycerides', 'mg/dL', 0, 150),
];
const _sugar = [
  LabParam('Fasting Glucose', 'mg/dL', 70, 100),
  LabParam('HbA1c', '%', 4, 5.7),
];
const _thyroid = [
  LabParam('TSH', 'µIU/mL', 0.4, 4.0),
  LabParam('T3', 'ng/dL', 80, 200),
  LabParam('T4', 'µg/dL', 5, 12),
];
const _vit = [
  LabParam('Vitamin D', 'ng/mL', 30, 100),
  LabParam('Vitamin B12', 'pg/mL', 200, 900),
];
const _kft = [
  LabParam('Creatinine', 'mg/dL', 0.6, 1.3),
  LabParam('Urea', 'mg/dL', 15, 40),
];
const _lft = [
  LabParam('SGPT (ALT)', 'U/L', 7, 56),
  LabParam('Bilirubin Total', 'mg/dL', 0.1, 1.2),
];

const labCatalog = <LabTest>[
  LabTest('p1', 'Full Body Checkup', '72 parameters · CBC, lipid, liver, kidney, thyroid, sugar, vitamins', 999, 72, [..._cbc, ..._lipid, ..._sugar, ..._thyroid, ..._kft, ..._lft], isPackage: true, fasting: true),
  LabTest('p2', 'Diabetes Care', '28 parameters · HbA1c, fasting & PP glucose, kidney markers', 699, 28, [..._sugar, ..._kft], isPackage: true, fasting: true),
  LabTest('p3', 'Heart Health', '35 parameters · lipid profile, hs-CRP, ECG advice', 1299, 35, [..._lipid, ..._cbc], isPackage: true, fasting: true),
  LabTest('p4', 'Thyroid Profile', 'T3, T4, TSH', 499, 3, _thyroid, isPackage: true),
  LabTest('p5', "Women's Wellness", '64 parameters · hormones, iron, vitamins, thyroid', 1499, 64, [..._cbc, ..._thyroid, ..._vit], isPackage: true, fasting: true),
  LabTest('t1', 'Complete Blood Count (CBC)', 'Hemoglobin, WBC, platelets', 349, 3, _cbc),
  LabTest('t2', 'HbA1c', '3-month average blood sugar', 450, 1, [LabParam('HbA1c', '%', 4, 5.7)]),
  LabTest('t3', 'Lipid Profile', 'Cholesterol, LDL, HDL, triglycerides', 550, 4, _lipid, fasting: true),
  LabTest('t4', 'Vitamin D (25-OH)', 'Vitamin D levels', 799, 1, [LabParam('Vitamin D', 'ng/mL', 30, 100)]),
  LabTest('t5', 'Vitamin B12', 'B12 levels', 650, 1, [LabParam('Vitamin B12', 'pg/mL', 200, 900)]),
  LabTest('t6', 'Fasting Blood Sugar', 'Glucose after 8-10 hr fast', 100, 1, [LabParam('Fasting Glucose', 'mg/dL', 70, 100)], fasting: true),
  LabTest('t7', 'Liver Function Test', 'SGPT, bilirubin', 599, 2, _lft),
];

const labStages = [
  'Booking confirmed',
  'Phlebotomist assigned',
  'On the way to collect sample',
  'Sample collected',
  'Report ready',
];

class LabBooking {
  final String id, patient, address;
  final List<LabTest> tests;
  final DateTime slot;
  final int total;
  int stage;
  LabBooking(this.id, this.tests, this.slot, this.patient, this.address, this.total,
      {this.stage = 0});
}

class ReportValue {
  final LabParam p;
  final double value;
  const ReportValue(this.p, this.value);
  String get status => value < p.min ? 'Low' : (value > p.max ? 'High' : 'Normal');
}

class LabReport {
  final String id, name;
  final DateTime date;
  final List<ReportValue> values;
  LabReport(this.id, this.name, this.date, this.values);
}

// ───────────────────────── Pharmacy ─────────────────────────
enum PillShape { round, capsule, oval }

class Medicine {
  final String id, name, pack, category;
  final int price;
  final bool rx;
  final PillShape shape;
  final Color color;
  const Medicine(this.id, this.name, this.pack, this.category, this.price, this.rx,
      this.shape, this.color);
}

const medicines = <Medicine>[
  Medicine('m1', 'Paracetamol 500mg', 'Strip of 15 tablets', 'Fever & Pain', 28, false, PillShape.round, Color(0xFFF2F2F2)),
  Medicine('m2', 'Vitamin D3 60K IU', 'Strip of 4 capsules', 'Supplements', 135, false, PillShape.capsule, Color(0xFFF5A623)),
  Medicine('m3', 'Cetirizine 10mg', 'Strip of 10 tablets', 'Allergy', 32, false, PillShape.oval, Color(0xFFFFFFFF)),
  Medicine('m4', 'Metformin 500mg', 'Strip of 20 tablets', 'Diabetes', 45, true, PillShape.round, Color(0xFFEFE9DD)),
  Medicine('m5', 'Atorvastatin 10mg', 'Strip of 15 tablets', 'Heart', 110, true, PillShape.oval, Color(0xFFFFB3A7)),
  Medicine('m6', 'Amlodipine 5mg', 'Strip of 15 tablets', 'Blood Pressure', 52, true, PillShape.round, Color(0xFFFFE7A0)),
  Medicine('m7', 'Pantoprazole 40mg', 'Strip of 15 tablets', 'Acidity', 98, true, PillShape.oval, Color(0xFFFFD27F)),
  Medicine('m8', 'Azithromycin 500mg', 'Strip of 3 tablets', 'Antibiotic', 119, true, PillShape.oval, Color(0xFFBFE3FF)),
  Medicine('m9', 'Omega-3 Fish Oil', 'Bottle of 60 capsules', 'Supplements', 420, false, PillShape.capsule, Color(0xFFFFC857)),
  Medicine('m10', 'ORS Electrolyte', 'Pack of 5 sachets', 'Hydration', 95, false, PillShape.round, Color(0xFFB6F0D4)),
  Medicine('m11', 'Levothyroxine 50mcg', 'Strip of 100 tablets', 'Thyroid', 175, true, PillShape.round, Color(0xFFE3D4FF)),
  Medicine('m12', 'Multivitamin Daily', 'Bottle of 30 tablets', 'Supplements', 299, false, PillShape.capsule, Color(0xFFFF9F80)),
];

const orderStages = ['Order placed', 'Packed', 'Out for delivery', 'Delivered'];

class CartLine {
  final Medicine med;
  int qty;
  CartLine(this.med, this.qty);
}

class Order {
  final String id;
  final List<CartLine> lines;
  final int subtotal, discount, delivery;
  final DateTime date;
  final bool refill;
  final String? rxName;
  int stage;
  Order(this.id, this.lines, this.subtotal, this.discount, this.delivery, this.date,
      this.refill, this.rxName,
      {this.stage = 0});
  int get total => subtotal - discount + delivery;
}

class Reminder {
  final String id, name, dose;
  final PillShape shape;
  final Color color;
  final List<TimeOfDay> times;
  final Set<String> taken = {};
  Reminder(this.id, this.name, this.dose, this.shape, this.color, this.times);
}

// ───────────────────────── Records & vitals ─────────────────────────
const recordCategories = ['Lab Reports', 'Prescriptions', 'Imaging', 'Bills', 'Other'];

class RecordFile {
  final String name, category;
  final DateTime date;
  final int sizeKb;
  RecordFile(this.name, this.category, this.date, this.sizeKb);
}

enum VitalType { bp, sugar, weight }

class Vital {
  final DateTime t;
  final double v;
  final double? v2; // diastolic for BP
  Vital(this.t, this.v, [this.v2]);
}

// ───────────────────────── App state ─────────────────────────
class DoctorFilters {
  String? specialty;
  String? city;
  String availability = 'Any'; // Any, Today, Tomorrow
  double minRating = 0;
  Tier? tier;
  String sort = 'Relevance'; // Relevance, Rating, Fee, Experience
  String query = '';

  bool get active =>
      specialty != null ||
      city != null ||
      availability != 'Any' ||
      minRating > 0 ||
      tier != null;
  void reset() {
    specialty = null;
    city = null;
    availability = 'Any';
    minRating = 0;
    tier = null;
  }
}

class AppState extends ChangeNotifier {
  String userName = 'Tanishq';
  String city = 'Bengaluru';
  bool isPlus = false;
  DateTime? plusUntil;

  final filters = DoctorFilters();
  final appointments = <Appointment>[];
  final _booked = <String>{};
  final chats = <int, List<ChatMsg>>{};
  final chatUnlocked = <int>{};

  final labBookings = <LabBooking>[];
  final reports = <LabReport>[];
  final labCart = <LabTest>[];

  final cart = <CartLine>[];
  final orders = <Order>[];
  bool refillSubscribed = false;
  DateTime? nextRefill;

  final reminders = <Reminder>[];
  final records = <RecordFile>[];
  final prescriptions = <Prescription>[];
  final vitals = <VitalType, List<Vital>>{
    VitalType.bp: [],
    VitalType.sugar: [],
    VitalType.weight: [],
  };

  void refresh() => notifyListeners();

  int _seq = 100;
  String nextId(String p) => '$p${_seq++}';

  AppState() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    // Past appointment with prescription
    final d = doctors[0];
    final rx = Prescription(
      'RX1001',
      d,
      now.subtract(const Duration(days: 20)),
      'Viral fever with throat infection',
      const [
        RxItem('Paracetamol 500mg', '1 tablet, 3 times a day', '5 days', 'After food'),
        RxItem('Cetirizine 10mg', '1 tablet at night', '5 days', 'After dinner'),
        RxItem('ORS Electrolyte', '1 sachet in 1 L water', '3 days', 'Sip through the day'),
      ],
      'Take rest, drink plenty of fluids and review if fever lasts beyond 3 days.',
    );
    prescriptions.add(rx);
    appointments.add(Appointment('A1001', d, now.subtract(const Duration(days: 20)), true, d.fee,
        status: 'Completed', rx: rx));
    // Upcoming appointment tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    final d2 = doctors[2];
    final ts = slotsFor(d2, tomorrow);
    final t = ts.isNotEmpty ? ts[ts.length ~/ 2] : DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11);
    appointments.add(Appointment('A1002', d2, t, true, d2.fee));
    _booked.add(_key(d2, t));

    // Lab report
    reports.add(LabReport('R1001', 'Complete Blood Count + Lipid', now.subtract(const Duration(days: 35)), [
      ReportValue(_cbc[0], 14.2),
      ReportValue(_cbc[1], 7.4),
      ReportValue(_cbc[2], 138),
      ReportValue(_lipid[0], 214),
      ReportValue(_lipid[1], 128),
      ReportValue(_lipid[2], 46),
      ReportValue(_lipid[3], 160),
    ]));

    records
      ..add(RecordFile('CBC_Lipid_Report.pdf', 'Lab Reports', now.subtract(const Duration(days: 35)), 412))
      ..add(RecordFile('Prescription_Dr_Mehta.pdf', 'Prescriptions', now.subtract(const Duration(days: 20)), 188))
      ..add(RecordFile('Chest_Xray.jpg', 'Imaging', now.subtract(const Duration(days: 90)), 2310))
      ..add(RecordFile('Pharmacy_Bill_Aug.pdf', 'Bills', now.subtract(const Duration(days: 45)), 96));

    // Vitals: 12 readings over ~ 3 weeks
    for (var i = 0; i < 12; i++) {
      final dt = now.subtract(Duration(days: (11 - i) * 2));
      vitals[VitalType.bp]!.add(Vital(dt, 118.0 + (i * 7) % 15, 76.0 + (i * 5) % 10));
      vitals[VitalType.sugar]!.add(Vital(dt, 90.0 + (i * 11) % 34));
      vitals[VitalType.weight]!.add(Vital(dt, 72.4 - i * 0.15 + (i % 3) * 0.1));
    }

    reminders
      ..add(Reminder('RM1', 'Metformin 500mg', '1 tablet · after breakfast & dinner', PillShape.round,
          const Color(0xFFEFE9DD), const [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 21, minute: 0)]))
      ..add(Reminder('RM2', 'Vitamin D3 60K IU', '1 capsule · weekly with milk', PillShape.capsule,
          const Color(0xFFF5A623), const [TimeOfDay(hour: 8, minute: 30)]))
      ..add(Reminder('RM3', 'Atorvastatin 10mg', '1 tablet · after dinner', PillShape.oval,
          const Color(0xFFFFB3A7), const [TimeOfDay(hour: 21, minute: 30)]));
  }

  // ── Doctors / booking ──
  String _key(Doctor d, DateTime t) => '${d.id}_${t.millisecondsSinceEpoch}';

  List<DateTime> availableSlots(Doctor d, DateTime day) {
    final cutoff = DateTime.now().add(const Duration(minutes: 30));
    return slotsFor(d, day)
        .where((s) => s.isAfter(cutoff) && !_booked.contains(_key(d, s)))
        .toList();
  }

  DateTime? nextSlot(Doctor d) {
    final today = DateTime.now();
    for (var i = 0; i < 14; i++) {
      final s = availableSlots(d, today.add(Duration(days: i)));
      if (s.isNotEmpty) return s.first;
    }
    return null;
  }

  List<Doctor> searchDoctors() {
    final f = filters;
    final now = DateTime.now();
    var list = doctors.where((d) {
      if (f.specialty != null && d.specialty != f.specialty) return false;
      if (f.city != null && d.city != f.city) return false;
      if (d.rating < f.minRating) return false;
      if (f.tier != null && d.tier != f.tier) return false;
      if (f.availability == 'Today' && availableSlots(d, now).isEmpty) return false;
      if (f.availability == 'Tomorrow' &&
          availableSlots(d, now.add(const Duration(days: 1))).isEmpty) {
        return false;
      }
      final q = f.query.trim().toLowerCase();
      if (q.isNotEmpty &&
          !('${d.name} ${d.specialty} ${d.clinic} ${d.area} ${d.city}'.toLowerCase().contains(q))) {
        return false;
      }
      return true;
    }).toList();
    switch (f.sort) {
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Fee':
        list.sort((a, b) => a.fee.compareTo(b.fee));
      case 'Experience':
        list.sort((a, b) => b.experience.compareTo(a.experience));
      default:
        // Relevance: prefer the user's city, then rating
        list.sort((a, b) {
          final ca = a.city == city ? 0 : 1, cb = b.city == city ? 0 : 1;
          return ca != cb ? ca.compareTo(cb) : b.rating.compareTo(a.rating);
        });
    }
    return list;
  }

  Appointment book(Doctor d, DateTime t, bool video) {
    final a = Appointment(nextId('A'), d, t, video, d.fee);
    appointments.insert(0, a);
    _booked.add(_key(d, t));
    notifyListeners();
    return a;
  }

  void cancel(Appointment a) {
    a.status = 'Cancelled';
    _booked.remove(_key(a.doctor, a.time));
    notifyListeners();
  }

  Prescription complete(Appointment a) {
    a.status = 'Completed';
    final items = switch (a.doctor.specialty) {
      'Cardiologist' => const [
          RxItem('Atorvastatin 10mg', '1 tablet at night', '30 days', 'After dinner'),
          RxItem('Amlodipine 5mg', '1 tablet in the morning', '30 days', 'After breakfast'),
        ],
      'Dermatologist' => const [
          RxItem('Cetirizine 10mg', '1 tablet at night', '10 days', 'After dinner'),
          RxItem('Clindamycin 1% gel', 'Apply thin layer', '14 days', 'Night, on clean skin'),
        ],
      'Diabetologist' => const [
          RxItem('Metformin 500mg', '1 tablet twice daily', '30 days', 'After meals'),
        ],
      _ => const [
          RxItem('Paracetamol 500mg', '1 tablet when needed (max 3/day)', '5 days', 'After food'),
          RxItem('Multivitamin Daily', '1 tablet daily', '30 days', 'After breakfast'),
        ],
    };
    final rx = Prescription(nextId('RX'), a.doctor, DateTime.now(), 'Consultation follow-up',
        items, 'Stay hydrated, get adequate sleep and book a follow-up in 2 weeks if symptoms persist.');
    a.rx = rx;
    prescriptions.insert(0, rx);
    notifyListeners();
    return rx;
  }

  // ── Chat ──
  List<ChatMsg> chatFor(Doctor d) => chats.putIfAbsent(d.id, () => [
        ChatMsg('Hello! I am ${d.name}. How can I help you today?', false),
      ]);

  bool chatFree(Doctor d) => isPlus || chatUnlocked.contains(d.id);

  void unlockChat(Doctor d) {
    chatUnlocked.add(d.id);
    notifyListeners();
  }

  void sendChat(Doctor d, String text) {
    chatFor(d).add(ChatMsg(text, true));
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1400), () {
      chatFor(d).add(ChatMsg(
          'Thanks for sharing. Please note your symptoms, how long you have had them, and any medicines you take. I will advise accordingly.',
          false));
      notifyListeners();
    });
  }

  // ── Plus ──
  void subscribePlus() {
    isPlus = true;
    plusUntil = DateTime.now().add(const Duration(days: 365));
    notifyListeners();
  }

  // ── Labs ──
  void toggleLab(LabTest t) {
    labCart.contains(t) ? labCart.remove(t) : labCart.add(t);
    notifyListeners();
  }

  int get labSubtotal => labCart.fold(0, (s, t) => s + t.price);
  int get labCollectionFee => labCart.isEmpty || labSubtotal >= 500 ? 0 : 50;

  LabBooking bookLab(DateTime slot, String patient, String address) {
    final b = LabBooking(nextId('L'), List.of(labCart), slot, patient, address,
        labSubtotal + labCollectionFee);
    labBookings.insert(0, b);
    labCart.clear();
    notifyListeners();
    return b;
  }

  void advanceLab(LabBooking b) {
    if (b.stage >= labStages.length - 1) return;
    b.stage++;
    if (b.stage == labStages.length - 1) {
      final params = <LabParam>[];
      for (final t in b.tests) {
        for (final p in t.params) {
          if (!params.any((e) => e.name == p.name)) params.add(p);
        }
      }
      final vals = <ReportValue>[];
      for (var i = 0; i < params.length; i++) {
        final p = params[i];
        final span = p.max - p.min;
        final lo = p.min == 0 ? 0.0 : p.min;
        // Deterministic spread: most normal, an occasional out-of-range value.
        final frac = [0.5, 0.3, 0.7, 1.12, 0.45, 0.2, 0.62][i % 7];
        var v = lo + span * frac;
        if (p.min == 0) v = p.max * (frac > 1 ? frac : frac + 0.2);
        vals.add(ReportValue(p, double.parse(v.toStringAsFixed(1))));
      }
      final name = b.tests.map((t) => t.name).join(' + ');
      reports.insert(0, LabReport(nextId('R'), name, DateTime.now(), vals));
      records.insert(0, RecordFile('${name.replaceAll(' ', '_')}.pdf', 'Lab Reports', DateTime.now(), 380));
    }
    notifyListeners();
  }

  // ── Pharmacy ──
  void addToCart(Medicine m) {
    final i = cart.indexWhere((l) => l.med.id == m.id);
    i >= 0 ? cart[i].qty++ : cart.add(CartLine(m, 1));
    notifyListeners();
  }

  void changeQty(CartLine l, int d) {
    l.qty += d;
    if (l.qty <= 0) cart.remove(l);
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (s, l) => s + l.qty);
  int get cartSubtotal => cart.fold(0, (s, l) => s + l.med.price * l.qty);
  bool get cartNeedsRx => cart.any((l) => l.med.rx);
  int cartDiscount(bool refill) => refill ? (cartSubtotal * kRefillDiscount).round() : 0;
  int cartDelivery() => cart.isEmpty || cartSubtotal >= 299 ? 0 : 40;

  Order placeOrder(bool refill, String? rxName) {
    final disc = cartDiscount(refill);
    final o = Order(nextId('O'), cart.map((l) => CartLine(l.med, l.qty)).toList(), cartSubtotal,
        disc, cartDelivery(), DateTime.now(), refill, rxName);
    orders.insert(0, o);
    cart.clear();
    if (refill) {
      refillSubscribed = true;
      nextRefill = DateTime.now().add(const Duration(days: 30));
    }
    notifyListeners();
    return o;
  }

  void advanceOrder(Order o) {
    if (o.stage < orderStages.length - 1) {
      o.stage++;
      notifyListeners();
    }
  }

  void cancelRefill() {
    refillSubscribed = false;
    nextRefill = null;
    notifyListeners();
  }

  // ── Reminders ──
  String _tk(TimeOfDay t) {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day} ${t.hour}:${t.minute}';
  }

  bool isTaken(Reminder r, TimeOfDay t) => r.taken.contains(_tk(t));

  void toggleTaken(Reminder r, TimeOfDay t) {
    final k = _tk(t);
    r.taken.contains(k) ? r.taken.remove(k) : r.taken.add(k);
    notifyListeners();
  }

  void addReminder(Reminder r) {
    reminders.add(r);
    notifyListeners();
  }

  void removeReminder(Reminder r) {
    reminders.remove(r);
    notifyListeners();
  }

  // ── Records / vitals ──
  void addRecord(String name, String category, int sizeKb) {
    records.insert(0, RecordFile(name, category, DateTime.now(), sizeKb));
    notifyListeners();
  }

  void removeRecord(RecordFile r) {
    records.remove(r);
    notifyListeners();
  }

  void addVital(VitalType t, double v, [double? v2]) {
    vitals[t]!.add(Vital(DateTime.now(), v, v2));
    notifyListeners();
  }
}

final app = AppState();
final tabIndex = ValueNotifier<int>(0);
