import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../Api/DataApi.dart';
import '../Api/stations_servicesApi.dart';
import '../Models/PinDataModel.dart';
import '../Models/RegionModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_View/DrawerView.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
const _yellow = Color(0xFFFFCB22);
class MapLocationStationScreen extends StatefulWidget {
  const MapLocationStationScreen({super.key});
  @override
  State<MapLocationStationScreen> createState() => _StationsState();
}
class _StationsState extends State<MapLocationStationScreen> {
  final _search = TextEditingController();
  GoogleMapController? _map;
  List<PinDataModel> _all = [];
  List<RegionModel> _regions = [];
  RegionModel? _region;
  CitiesModel? _city;
  PinDataModel? _selected;
  Position? _position;
  bool _loading = true, _failed = false, _list = false;
  BitmapDescriptor? _normalPin, _selectedPin;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle style(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight);
  bool valid(PinDataModel p) => p.lat.isFinite && p.lng.isFinite &&
    p.lat.abs() <= 90 && p.lng.abs() <= 180 && (p.lat != 0 || p.lng != 0);
  List<PinDataModel> get filtered {
    final query = _search.text.trim().toLowerCase();
    return _all.where((p) => (_region == null || p.region_id == '${_region!.id}') &&
      (_city == null || p.cityId == '${_city!.id}') &&
      (query.isEmpty || '${p.name ?? ''} ${p.address ?? ''}'.toLowerCase().contains(query))).toList();
  }
  @override
  void initState() { super.initState(); _load(); _pins(); }
  @override
  void dispose() { _search.dispose(); _map?.dispose(); super.dispose(); }
  Future<void> _load() async {
    setState(() { _loading = true; _failed = false; });
    try {
      final stations = await Allstations(context);
      if (!mounted) return;
      final regions = await GetRegion(context);
      if (!mounted) return;
      setState(() { _all = stations ?? []; _regions = regions ?? [];
        _failed = stations == null; _selected = null; _region = null; _city = null; });
      await _fit();
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _pins() async {
    final data = await rootBundle.load('lib/assets/fal_brand.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final logo = (await codec.getNextFrame()).image;
    Future<BitmapDescriptor> draw(Color color) async {
      final recorder = ui.PictureRecorder(); final canvas = Canvas(recorder);
      final path = Path()..moveTo(48, 118)..quadraticBezierTo(0, 68, 4, 43)
        ..cubicTo(8, -8, 88, -8, 92, 43)..quadraticBezierTo(96, 68, 48, 118)..close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawCircle(const Offset(48, 45), 31, Paint()..color = Colors.white);
      canvas.drawImageRect(logo, Rect.fromLTWH(0, logo.height * .19,
        logo.width.toDouble(), logo.height * .55), const Rect.fromLTWH(19, 29, 58, 32), Paint()..filterQuality = FilterQuality.high);
      final picture = recorder.endRecording(); final image = await picture.toImage(96, 120);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final icon = BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), width: 40, height: 50);
      image.dispose(); picture.dispose(); return icon;
    }
    final normal = await draw(_blue); final selected = await draw(_yellow);
    logo.dispose(); codec.dispose();
    if (mounted) setState(() { _normalPin = normal; _selectedPin = selected; });
  }
  Future<void> _fit() async {
    final points = filtered.where(valid).toList();
    if (_list || !mounted || _map == null || points.isEmpty) return;
    if (points.length == 1) {
      await _map!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(points.first.lat, points.first.lng), 13));
      return;
    }
    double south = points.first.lat, north = south, west = points.first.lng, east = west;
    for (final p in points) { if (p.lat < south) south = p.lat; if (p.lat > north) north = p.lat;
      if (p.lng < west) west = p.lng; if (p.lng > east) east = p.lng; }
    if ((north - south).abs() < .001 && (east - west).abs() < .001) {
      await _map!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(south, west), 13));
    } else { await _map!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east)), 55)); }
  }
  void _filterChanged() { setState(() => _selected = null); _fit(); }
  Future<void> _locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) { _message(t('فعّل خدمة الموقع على جهازك', 'Enable location services')); return; }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _message(t('يلزم السماح بالموقع لإظهار موقعك', 'Location permission is required')); return;
    }
    try {
      final position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _position = position);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 13));
    } catch (_) { _message(t('تعذر تحديد الموقع، حاول مجددًا', 'Could not get your location. Try again')); }
  }
  void _message(String text) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text))); }
  Future<void> _directions(PinDataModel p) async {
    try { await MapsLauncher.launchCoordinates(p.lat, p.lng, p.name ?? ''); }
    catch (_) { _message(t('تعذر فتح الاتجاهات', 'Could not open directions')); }
  }
  Widget _dropdown<T>(T? value, String hint, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) =>
    Container(padding: const EdgeInsets.symmetric(horizontal: 10), height: 43,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4DFEB)), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value,
        hint: Text(hint, style: style(11)), isExpanded: true, style: style(11),
        icon: const Icon(Icons.keyboard_arrow_down, color: _blue, size: 19), items: items, onChanged: onChanged)));
  @override
  Widget build(BuildContext context) {
    final data = filtered;
    final markers = data.where(valid).map((p) => Marker(markerId: MarkerId('${p.id}'),
      position: LatLng(p.lat, p.lng), icon: p.id == _selected?.id
        ? (_selectedPin ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow))
        : (_normalPin ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
      onTap: () => setState(() => _selected = p))).toSet();
    return Scaffold(backgroundColor: Colors.white, drawer: DrawerList(context), body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 12), child: Column(children: [
        Row(children: [Image.asset('lib/assets/fal_brand.png', width: 66, height: 52),
          Expanded(child: Center(child: Text(t('المحطات', 'Stations'), style: style(23, weight: FontWeight.w800)))),
          Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: t('القائمة', 'Menu'), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F6FC)),
            icon: const Icon(Icons.person_outline, color: _blue))),
        ]),
        const SizedBox(height: 8),
        TextField(controller: _search, onChanged: (_) => _filterChanged(), style: style(13),
          decoration: InputDecoration(hintText: t('ابحث عن محطة أو مدينة', 'Search stations or cities'),
            hintStyle: style(12, color: const Color(0xFF8595A6)), prefixIcon: const Icon(Icons.search, color: _ink),
            suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); _filterChanged(); }, icon: const Icon(Icons.close, size: 18)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCE6EF))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _blue)))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _dropdown<RegionModel>(_region, t('المنطقة', 'Region'),
            [DropdownMenuItem<RegionModel>(value: null, child: Text(t('كل المناطق', 'All regions'))),
              ..._regions.map((r) => DropdownMenuItem(value: r, child: Text(t(r.nameAr ?? '', r.nameEn ?? ''), overflow: TextOverflow.ellipsis)))],
            (r) { setState(() { _region = r; _city = null; }); _filterChanged(); })),
          const SizedBox(width: 8),
          Expanded(child: _dropdown<CitiesModel>(_city, t('المدينة', 'City'),
            [DropdownMenuItem<CitiesModel>(value: null, child: Text(t('كل المدن', 'All cities'))),
              ...(_region?.cities ?? <CitiesModel>[]).map((c) => DropdownMenuItem(value: c, child: Text(t(c.nameAr ?? '', c.nameEn ?? ''), overflow: TextOverflow.ellipsis)))],
            (c) { setState(() => _city = c); _filterChanged(); })),
          if (_region != null || _city != null) IconButton(tooltip: t('مسح المرشحات', 'Clear filters'),
            onPressed: () { setState(() { _region = null; _city = null; }); _filterChanged(); }, icon: const Icon(Icons.filter_alt_off_outlined, color: _blue, size: 20)),
          const SizedBox(width: 8),
          _viewButton(false, Icons.map_outlined), _viewButton(true, Icons.list),
        ]),
      ])),
      if (_loading) const LinearProgressIndicator(minHeight: 2, color: _yellow, backgroundColor: Color(0xFFE5EEF7)),
      Expanded(child: _failed ? _empty(t('تعذر تحميل المحطات', 'Could not load stations'), retry: true)
        : _list ? (data.isEmpty ? _empty(t('لا توجد محطات مطابقة', 'No matching stations'))
          : ListView.separated(padding: const EdgeInsets.all(16), itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _stationCard(data[index], compact: true)))
        : Stack(children: [
          GoogleMap(initialCameraPosition: const CameraPosition(target: LatLng(24.729, 46.704), zoom: 6),
            onMapCreated: (controller) { _map = controller; _fit(); }, markers: markers,
            myLocationEnabled: _position != null, myLocationButtonEnabled: false,
            zoomControlsEnabled: false, mapToolbarEnabled: false,
            padding: EdgeInsets.only(bottom: _selected == null ? 0 : 175),
            onTap: (_) => setState(() => _selected = null)),
          Positioned(left: 16, bottom: _selected == null ? 20 : 195,
            child: Material(color: Colors.white, elevation: 2, borderRadius: BorderRadius.circular(18),
              child: IconButton(tooltip: t('موقعي الحالي', 'My location'), onPressed: _locate,
                icon: const Icon(Icons.my_location, color: _blue)))),
          if (!_loading && data.isEmpty) Positioned(top: 14, left: 16, right: 16,
            child: Material(color: Colors.white, borderRadius: BorderRadius.circular(12),
              child: Padding(padding: const EdgeInsets.all(12), child: Text(t('لا توجد محطات مطابقة', 'No matching stations'), style: style(13))))),
          if (_selected != null) Positioned(bottom: 0, left: 0, right: 0, child: _stationCard(_selected!)),
        ])),
    ]));
  }
  Widget _viewButton(bool list, IconData icon) => Tooltip(message: list ? t('قائمة', 'List') : t('خريطة', 'Map'),
    child: InkWell(onTap: () => setState(() { _list = list; _selected = null; }), borderRadius: BorderRadius.circular(10),
      child: Container(height: 43, width: 35, decoration: BoxDecoration(color: _list == list ? _blue : const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 21, color: _list == list ? Colors.white : _blue))));
  Widget _empty(String label, {bool retry = false}) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.location_off_outlined, color: _blue, size: 40), const SizedBox(height: 12),
    Text(label, style: style(14)), if (retry) TextButton(onPressed: _load, child: Text(t('حاول مجددًا', 'Retry'))),
  ]));
  Widget _stationCard(PinDataModel p, {bool compact = false}) {
    final distance = _position == null || !valid(p) ? null
      : Geolocator.distanceBetween(_position!.latitude, _position!.longitude, p.lat, p.lng) / 1000;
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white,
      borderRadius: compact ? BorderRadius.circular(18) : const BorderRadius.vertical(top: Radius.circular(24)),
      border: Border.all(color: const Color(0xFFDFE8F1))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!compact) Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFFD4DFEA), borderRadius: BorderRadius.circular(8)))),
        Row(children: [Expanded(child: Text(p.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: style(19, weight: FontWeight.w800))),
          if (distance != null) Text('${distance.toStringAsFixed(1)} ${t('كم', 'km')}', style: style(12, color: _blue)),
          if (!compact) IconButton(onPressed: () => setState(() => _selected = null), icon: const Icon(Icons.close, size: 18)),
        ]),
        const SizedBox(height: 4),
        Text(p.address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: style(12, color: const Color(0xFF64748B))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: valid(p) ? () => _directions(p) : null,
            style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.navigation_outlined, size: 18), label: Text(t('الاتجاهات', 'Directions'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)))),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(onPressed: () => Navigator.pushNamed(context, serviceRoute, arguments: '${p.id}'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE8F3FD), foregroundColor: _blue,
              padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.format_list_bulleted, size: 18), label: Text(t('خدمات المحطة', 'Services'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 11)))),
        ]),
      ]));
  }
}
