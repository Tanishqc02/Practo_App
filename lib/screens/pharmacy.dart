import 'package:flutter/material.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'reminders.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});
  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) => Scaffold(
            appBar: AppBar(
              title: const Text('Medicines'),
              actions: [
                IconButton(
                  tooltip: 'Pill reminders',
                  icon: const Icon(Icons.alarm_rounded),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
                ),
                IconButton(
                  icon: Badge(isLabelVisible: app.cartCount > 0, label: Text('${app.cartCount}'), child: const Icon(Icons.shopping_cart_outlined)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                ),
              ],
              bottom: const TabBar(tabs: [Tab(text: 'Shop'), Tab(text: 'Orders & refills')]),
            ),
            body: TabBarView(children: [_shop(context), _orders(context)]),
          ),
        ),
      );

  Widget _shop(BuildContext context) {
    final list = medicines.where((m) => q.isEmpty || '${m.name} ${m.category}'.toLowerCase().contains(q.toLowerCase())).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextField(
        onChanged: (v) => setState(() => q = v),
        decoration: const InputDecoration(hintText: 'Search medicines', prefixIcon: Icon(Icons.search_rounded), isDense: true),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kBlue.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Expanded(child: Text('Subscribe to monthly refills at checkout and save 5% on every order.', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          const Row(mainAxisSize: MainAxisSize.min, children: [
            PillImage(PillShape.capsule, Color(0xFFF5A623), size: 40),
            PillImage(PillShape.round, Color(0xFFFFE7A0), size: 40),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      for (final m in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                PillImage(m.shape, m.color, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(m.pack, style: const TextStyle(color: kMuted, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(inr(m.price), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(width: 8),
                      if (m.rx) const Tag('Rx required', color: kRed, icon: Icons.description_outlined),
                    ]),
                  ]),
                ),
                FilledButton(
                  onPressed: () {
                    app.addToCart(m);
                    toast(context, '${m.name} added to cart');
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14)),
                  child: const Text('Add'),
                ),
              ]),
            ),
          ),
        ),
    ]);
  }

  Widget _orders(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        if (app.refillSubscribed)
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0x1A1FA67A), child: Icon(Icons.autorenew_rounded, color: kGreen)),
              title: const Text('Monthly refill active · 5% off', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Next refill reminder: ${fmtDateLong(app.nextRefill!)}'),
              trailing: TextButton(onPressed: app.cancelRefill, child: const Text('Cancel')),
            ),
          ),
        if (app.orders.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 80), child: EmptyState(Icons.local_shipping_outlined, 'No orders yet', 'Your medicine orders and deliveries appear here.')),
        for (final o in app.orders)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('Order ${o.id}', style: const TextStyle(fontWeight: FontWeight.w800))),
                    if (o.refill) const Tag('Refill', color: kGreen),
                    const SizedBox(width: 8),
                    Text(inr(o.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                  Text(o.lines.map((l) => '${l.med.name} ×${l.qty}').join(', '), style: const TextStyle(color: kMuted)),
                  if (o.rxName != null) Text('Prescription: ${o.rxName}', style: const TextStyle(color: kMuted, fontSize: 12.5)),
                  const SizedBox(height: 12),
                  StageTracker(stages: orderStages, current: o.stage),
                  if (o.stage < orderStages.length - 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(onPressed: () => app.advanceOrder(o), icon: const Icon(Icons.fast_forward_rounded, size: 18), label: const Text('Simulate next step (demo)')),
                    ),
                ]),
              ),
            ),
          ),
      ]);
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool refill = false;
  String? rxName;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final needsRx = app.cartNeedsRx;
          final disc = app.cartDiscount(refill);
          final total = app.cartSubtotal - disc + app.cartDelivery();
          return Scaffold(
            appBar: AppBar(title: const Text('Your cart')),
            bottomNavigationBar: app.cart.isEmpty
                ? null
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: FilledButton(
                        onPressed: needsRx && rxName == null
                            ? null
                            : () {
                                app.placeOrder(refill, rxName);
                                Navigator.pop(context);
                                toast(context, 'Order placed! Track it under Orders & refills');
                              },
                        child: Text(needsRx && rxName == null ? 'Upload prescription to continue' : 'Place order · ${inr(total)}'),
                      ),
                    ),
                  ),
            body: app.cart.isEmpty
                ? const EmptyState(Icons.shopping_cart_outlined, 'Your cart is empty', 'Add medicines from the shop.')
                : ListView(padding: const EdgeInsets.all(16), children: [
                    for (final l in app.cart)
                      Card(
                        child: ListTile(
                          leading: PillImage(l.med.shape, l.med.color, size: 44),
                          title: Text(l.med.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(inr(l.med.price * l.qty)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => app.changeQty(l, -1)),
                            Text('${l.qty}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => app.changeQty(l, 1)),
                          ]),
                        ),
                      ),
                    if (needsRx) ...[
                      const SectionTitle('Prescription required'),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: rxName != null
                              ? Row(children: [
                                  const Icon(Icons.check_circle_rounded, color: kGreen),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(rxName!, style: const TextStyle(fontWeight: FontWeight.w700))),
                                  TextButton(onPressed: () => setState(() => rxName = null), child: const Text('Remove')),
                                ])
                              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('Some medicines need a valid prescription.', style: TextStyle(color: kMuted)),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(child: OutlinedButton.icon(onPressed: _pickSaved, icon: const Icon(Icons.description_outlined), label: const Text('Saved Rx'))),
                                    const SizedBox(width: 10),
                                    Expanded(child: FilledButton.icon(onPressed: _upload, icon: const Icon(Icons.upload_file_rounded), label: const Text('Upload'))),
                                  ]),
                                ]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Card(
                      child: SwitchListTile(
                        value: refill,
                        onChanged: (v) => setState(() => refill = v),
                        title: const Text('Monthly refill subscription', style: TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('Save 5% on this and every monthly order. Cancel anytime.'),
                        secondary: const Icon(Icons.autorenew_rounded, color: kGreen),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(children: [
                          _line('Item total', inr(app.cartSubtotal)),
                          if (refill) _line('Refill subscription (5%)', '− ${inr(disc)}', green: true),
                          _line('Delivery', app.cartDelivery() == 0 ? 'FREE' : inr(app.cartDelivery()), green: app.cartDelivery() == 0),
                          const Divider(),
                          _line('To pay', inr(total), bold: true),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(child: Text('Free delivery above ₹299 · Demo checkout, no real payment.', style: TextStyle(color: kMuted, fontSize: 12))),
                  ]),
          );
        },
      );

  void _upload() {
    final c = TextEditingController(text: 'prescription_photo.jpg');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload prescription'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('File picking is simulated in this demo. Name the file to attach:', style: TextStyle(color: kMuted)),
          const SizedBox(height: 10),
          TextField(controller: c, decoration: const InputDecoration(labelText: 'File name')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final n = c.text.trim().isEmpty ? 'prescription.jpg' : c.text.trim();
              setState(() => rxName = n);
              app.addRecord(n, 'Prescriptions', 850);
              Navigator.pop(ctx);
            },
            child: const Text('Attach'),
          ),
        ],
      ),
    );
  }

  void _pickSaved() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          for (final r in app.prescriptions)
            ListTile(
              leading: DoctorAvatar(r.doctor, size: 40),
              title: Text(r.diagnosis),
              subtitle: Text('${r.doctor.name} · ${fmtDateLong(r.date)}'),
              onTap: () {
                setState(() => rxName = '${r.id} · ${r.doctor.name}');
                Navigator.pop(ctx);
              },
            ),
        ]),
      ),
    );
  }

  Widget _line(String a, String b, {bool bold = false, bool green = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w800 : null))),
          Text(b, style: TextStyle(fontWeight: FontWeight.w800, fontSize: bold ? 16 : null, color: green ? kGreen : null)),
        ]),
      );
}
