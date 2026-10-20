import 'package:flutter/material.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/FalDesign.dart';
import '../Shared_View/FalField.dart';
import 'contact_us_page.dart';

class StationTransportationPage extends StatefulWidget {
  const StationTransportationPage({super.key, this.prepareMessage});
  final Future<void> Function(BuildContext, String, String)? prepareMessage;
  @override
  State<StationTransportationPage> createState() => _TransportState();
}
class _TransportState extends State<StationTransportationPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _phone = TextEditingController(), _station = TextEditingController(), _address = TextEditingController(), _notes = TextEditingController();
  // Preserve the choices configured in the original app until the service supplies a catalog.
  final _fuels = [90, 92, 95], _quantities = [10, 20, 30];
  final Map<int, int> _items = {};
  int _fuel = 90, _quantity = 10;
  double? _lat, _lng;
  bool _opening = false;
  @override
  void initState() { super.initState(); _name.text = DelegateData.delegateData?.name ?? ''; _phone.text = DelegateData.delegateData?.mobile ?? ''; }
  @override
  void dispose() { for (final controller in [_name, _phone, _station, _address, _notes]) { controller.dispose(); } super.dispose(); }
  Future<void> _location() async {
    final saved = await Navigator.pushNamed(context, MapLocationRoute);
    if (mounted && saved == true) setState(() { _address.text = AddressData.addressData; _lat = AddressData.lat == 0 && AddressData.lng == 0 ? null : AddressData.lat; _lng = _lat == null ? null : AddressData.lng; });
  }
  Future<void> _prepare() async {
    if (_opening || !_form.currentState!.validate()) return;
    if (_items.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('أضف نوع الوقود والكمية إلى القائمة', 'Add fuel and quantity to the list')))); return; }
    final message = [falText('استفسار عن نقل الوقود', 'Fuel transport inquiry'),
      '${falText('الاسم', 'Name')}: ${_name.text.trim()}', '${falText('المحطة', 'Station')}: ${_station.text.trim()}',
      '${falText('العنوان', 'Address')}: ${_address.text.trim()}',
      for (final item in _items.entries) '${falText('وقود', 'Fuel')} ${item.key} — ${falText('الكمية', 'Quantity')}: ${item.value}',
      if (_lat != null && _lng != null) 'https://www.google.com/maps?q=$_lat,$_lng',
      if (_notes.text.trim().isNotEmpty) _notes.text.trim(),
    ].join('\n');
    setState(() => _opening = true);
    try {
      if (widget.prepareMessage != null) { await widget.prepareMessage!(context, message, normalizeCartNumber(_phone.text)); }
      else { await Navigator.push(context, MaterialPageRoute(builder: (_) => ConnectUsPage(initialMessage: message, initialMobile: normalizeCartNumber(_phone.text)))); }
    } finally { if (mounted) setState(() => _opening = false); }
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('نقل الوقود', 'Fuel transport'),
    bottom: falButton(falText('متابعة مع الدعم', 'Continue with support'), _opening ? null : _prepare),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
      falCard([const Icon(Icons.local_shipping_outlined, size: 46, color: falBlue), const SizedBox(height: 10), Text(falText('جهّز تفاصيل احتياجك', 'Prepare your requirements'), textAlign: TextAlign.center, style: falStyle(21, weight: FontWeight.w800))], color: const Color(0xFFEEF6FC)),
      FalField(controller: _name, label: falText('الاسم', 'Name'), icon: Icons.person_outline),
      FalField(controller: _phone, label: falText('رقم الجوال', 'Mobile number'), icon: Icons.phone_outlined, phone: true),
      FalField(controller: _station, label: falText('اسم المحطة', 'Station name'), icon: Icons.local_gas_station_outlined),
      FalField(controller: _address, label: falText('عنوان المحطة', 'Station address'), icon: Icons.location_on_outlined, onChanged: (_) { _lat = null; _lng = null; }),
      OutlinedButton.icon(onPressed: _location, icon: const Icon(Icons.map_outlined), label: Text(falText('تحديد الموقع', 'Choose location'))), const SizedBox(height: 24),
      Row(children: [Expanded(child: DropdownButtonFormField<int>(initialValue: _fuel, decoration: InputDecoration(labelText: falText('نوع الوقود', 'Fuel type')),
        items: _fuels.map((value) => DropdownMenuItem(value: value, child: Text('${falText('وقود', 'Fuel')} $value'))).toList(), onChanged: (value) => setState(() => _fuel = value!))),
        const SizedBox(width: 12), Expanded(child: DropdownButtonFormField<int>(initialValue: _quantity, decoration: InputDecoration(labelText: falText('الكمية', 'Quantity')),
          items: _quantities.map((value) => DropdownMenuItem(value: value, child: Text('$value'))).toList(), onChanged: (value) => setState(() => _quantity = value!)))]),
      const SizedBox(height: 14), OutlinedButton.icon(onPressed: () => setState(() => _items[_fuel] = _quantity), icon: const Icon(Icons.add), label: Text(falText('إضافة للقائمة', 'Add to list'))),
      const SizedBox(height: 14), for (final item in _items.entries) falCard([Row(children: [Expanded(child: Text('${falText('وقود', 'Fuel')} ${item.key} — ${falText('الكمية', 'Quantity')}: ${item.value}', style: falStyle(14))),
        IconButton(tooltip: falText('إزالة الوقود', 'Remove fuel'), onPressed: () => setState(() => _items.remove(item.key)), icon: const Icon(Icons.delete_outline, color: Color(0xFFB42318)))] )], color: const Color(0xFFEEF6FC)),
      FalField(controller: _notes, label: falText('ملاحظات إضافية (اختياري)', 'Additional notes (optional)'), icon: Icons.notes_outlined, optional: true, lines: 3),
      falCard([Text(falText('سيتم تجهيز التفاصيل في رسالة لفريقنا لاستكمال الطلب. راجع الرسالة ثم أرسلها من شاشة التواصل.', 'Your details will be prepared as a message to our team. Review and send it from the contact screen.'), style: falStyle(13, weight: FontWeight.w400))], color: const Color(0xFFEEF6FC)),
    ])));
}
