import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/FalDesign.dart';
import '../Shared_View/FalField.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key, this.initialManual = true});
  final bool initialManual;
  @override
  State<MapLocationScreen> createState() => _LocationState();
}
class _LocationState extends State<MapLocationScreen> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController(), _lat = TextEditingController(), _lng = TextEditingController();
  late bool _manual;
  bool _locating = false;
  int _lookup = 0;
  GoogleMapController? _map;
  LatLng? _point;
  @override
  void initState() { super.initState(); _manual = widget.initialManual; }
  @override
  void dispose() { _lookup++; _map?.dispose(); _address.dispose(); _lat.dispose(); _lng.dispose(); super.dispose(); }
  Future<void> _select(LatLng point) async {
    final lookup = ++_lookup;
    final previousAddress = _address.text;
    setState(() { _point = point; _lat.text = point.latitude.toStringAsFixed(6); _lng.text = point.longitude.toStringAsFixed(6); });
    try {
      final places = await placemarkFromCoordinates(point.latitude, point.longitude).timeout(const Duration(seconds: 10));
      if (!mounted || lookup != _lookup || _address.text != previousAddress || places.isEmpty) return;
      final place = places.first;
      final parts = [place.street, place.locality, place.administrativeArea, place.country].whereType<String>().where((part) => part.trim().isNotEmpty).toSet();
      if (parts.isNotEmpty) setState(() => _address.text = parts.join('، '));
    } catch (_) { /* Address can always be entered manually. */ }
  }
  Future<void> _myLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw const FormatException();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw const FormatException();
      final position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      await _select(point);
      if (mounted && !_manual) await _map?.animateCamera(CameraUpdate.newLatLngZoom(point, 15));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر تحديد موقعك. يمكنك إدخال العنوان يدويًا.', 'Unable to locate you. You can enter the address manually.'))));
    } finally { if (mounted) setState(() => _locating = false); }
  }
  String? _coordinate(String? raw, double maximum, TextEditingController other) {
    if ((raw ?? '').trim().isEmpty && other.text.trim().isEmpty) return null;
    final value = double.tryParse(normalizeCartNumber(raw ?? ''));
    if (value == null || !value.isFinite || value.abs() > maximum) return falText('إحداثيات غير صالحة', 'Invalid coordinates');
    return null;
  }
  void _save() {
    if (!_form.currentState!.validate()) return;
    AddressData.addressData = _address.text.trim();
    AddressData.lat = double.tryParse(normalizeCartNumber(_lat.text)) ?? 0;
    AddressData.lng = double.tryParse(normalizeCartNumber(_lng.text)) ?? 0;
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('تحديد الموقع', 'Choose location'), loading: _locating,
    bottom: falButton(falText('تثبيت العنوان', 'Confirm address'), _locating ? null : _save),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
      Text(falText('اختر عنوان المحطة', 'Choose the station address'), style: falStyle(24, weight: FontWeight.w800)),
      const SizedBox(height: 8), Text(falText('يمكنك إدخال العنوان يدويًا أو تحديد نقطة على الخريطة', 'Enter the address manually or choose a point on the map'), style: falStyle(13, weight: FontWeight.w400)),
      const SizedBox(height: 20), SegmentedButton<bool>(segments: [ButtonSegment(value: false, label: Text(falText('الخريطة', 'Map')), icon: const Icon(Icons.map_outlined)),
        ButtonSegment(value: true, label: Text(falText('إدخال يدوي', 'Manual')), icon: const Icon(Icons.edit_location_alt_outlined))], selected: {_manual}, onSelectionChanged: (values) => setState(() { _manual = values.first; if (_manual) _map = null; })),
      const SizedBox(height: 20),
      if (!_manual) ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(height: 270, child: GoogleMap(
        initialCameraPosition: CameraPosition(target: _point ?? const LatLng(24.72909, 46.70469), zoom: _point == null ? 10 : 15),
        onMapCreated: (controller) { if (mounted) _map = controller; }, onTap: _select,
        markers: _point == null ? {} : {Marker(markerId: const MarkerId('selected'), position: _point!, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure))},
        myLocationButtonEnabled: false, zoomControlsEnabled: false))),
      OutlinedButton.icon(onPressed: _myLocation, icon: const Icon(Icons.my_location), label: Text(falText('استخدام موقعي', 'Use my location'))),
      const SizedBox(height: 20), FalField(controller: _address, label: falText('عنوان المحطة', 'Station address'), icon: Icons.location_on_outlined, lines: 2),
      Text(falText('الإحداثيات (اختياري)', 'Coordinates (optional)'), style: falStyle(14)), const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: TextFormField(controller: _lat, textDirection: TextDirection.ltr, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: falText('خط العرض', 'Latitude')), validator: (raw) => _coordinate(raw, 90, _lng))), const SizedBox(width: 12),
        Expanded(child: TextFormField(controller: _lng, textDirection: TextDirection.ltr, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(labelText: falText('خط الطول', 'Longitude')), validator: (raw) => _coordinate(raw, 180, _lat)))]),
      const SizedBox(height: 24),
    ])));
}
