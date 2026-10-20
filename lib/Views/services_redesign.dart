import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Api/SetvicesApi.dart';
import '../Models/DataModel.dart';
import '../Models/ServicesModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/DrawerView.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class ServicesPage extends StatefulWidget {
  final String id;
  const ServicesPage({required this.id, super.key});
  @override
  State<ServicesPage> createState() => _ServicesState();
}
class _ServicesState extends State<ServicesPage> {
  final _search = TextEditingController();
  List<ServicesModel> _services = [];
  bool _loading = true, _failed = false;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.55);
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  Future<void> _load() async {
    setState(() { _loading = true; _failed = false; });
    try {
      final data = await GetAllServices(context, widget.id);
      if (!mounted) return;
      setState(() { _failed = data == null; _services = data ?? [];
        ServicesData.serviceData = _services; });
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  void _details(ServicesModel service) {
    FocusScope.of(context).unfocus();
    for (final s in _services) { s.selected = s.id == service.id; s.type = '1'; }
    ServicesData.serviceData = _services;
    Navigator.pushNamed(context, NewServiceRoute,
      arguments: DataModel(service.id, service.name ?? '', service.img ?? '', service.desc ?? '', service.icon ?? ''));
  }
  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final data = _services.where((s) => query.isEmpty ||
      '${s.name ?? ''} ${s.desc ?? ''}'.toLowerCase().contains(query)).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white, drawer: DrawerList(context),
        body: SafeArea(top: widget.id.isNotEmpty, child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 0), child: Column(children: [
            Row(children: [Image.asset('lib/assets/fal_brand.png', width: 76, height: 58),
              Expanded(child: Center(child: Text(t('الخدمات', 'Services'), style: text(24, weight: FontWeight.w800)))),
              if (widget.id.isNotEmpty) IconButton(tooltip: t('رجوع', 'Back'), onPressed: () => Navigator.pop(context),
                icon: const BackButtonIcon())
              else Builder(builder: (context) => IconButton(tooltip: t('القائمة', 'Menu'),
                onPressed: () => Scaffold.of(context).openDrawer(),
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F6FC)),
                icon: const Icon(Icons.person_outline, color: _blue))),
            ]),
            const SizedBox(height: 14),
            Text(widget.id.isEmpty ? t('اكتشف خدمات فلل', 'Discover FAL services') : t('خدمات المحطة', 'Station services'),
              style: text(22, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(t('حلول متكاملة لرحلتك وأعمالك', 'Solutions for your journey and business'),
              textAlign: TextAlign.center, style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)),
            const SizedBox(height: 18),
            TextField(controller: _search, onChanged: (_) => setState(() {}), style: text(13),
              decoration: InputDecoration(hintText: t('ابحث عن خدمة', 'Search services'),
                hintStyle: text(13, color: const Color(0xFF64748B)), filled: true, fillColor: const Color(0xFFEAF4FD),
                prefixIcon: const Icon(Icons.search, color: _blue),
                suffixIcon: query.isEmpty ? null : IconButton(tooltip: t('مسح البحث', 'Clear search'),
                  onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close, size: 18)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
            const SizedBox(height: 14),
          ])),
          if (_loading) const LinearProgressIndicator(minHeight: 2, color: Color(0xFFFFCB22), backgroundColor: Color(0xFFEAF4FD)),
          Expanded(child: RefreshIndicator(onRefresh: _load, color: _blue,
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              physics: const AlwaysScrollableScrollPhysics(), children: [
              if (!_loading && (_failed || data.isEmpty)) Padding(padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(children: [const Icon(Icons.search_off_outlined, size: 40, color: _blue),
                  const SizedBox(height: 12),
                  Text(_failed ? t('تعذر تحميل الخدمات', 'Could not load services') :
                    query.isEmpty ? t('لا توجد خدمات حاليًا', 'No services available') : t('لا توجد خدمات مطابقة', 'No matching services'),
                    style: text(14)),
                  if (_failed) TextButton(onPressed: _load, child: Text(t('حاول مجددًا', 'Retry'))),
                ])),
              for (final service in data) _card(service),
              if (data.isNotEmpty) Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [const Icon(Icons.info_outline, color: _blue, size: 21), const SizedBox(width: 8),
                  Expanded(child: Text(t('اختر الخدمة لمعرفة المزيد', 'Select a service to learn more'), style: text(12, color: _blue)))])),
            ]))),
        ])),
      ),
    );
  }
  Widget _card(ServicesModel service) {
    final name = service.name ?? '';
    final lower = name.toLowerCase();
    final station = lower.contains('وقود') || lower.contains('محط') || lower.contains('fuel') || lower.contains('station');
    final logistics = lower.contains('لوجست') || lower.contains('جمرك') || lower.contains('نقل') || lower.contains('logist') || lower.contains('transport');
    final alignment = station ? Alignment.centerLeft : logistics ? Alignment.center : Alignment.centerRight;
    final description = (service.desc ?? '').trim();
    return Padding(padding: const EdgeInsets.only(bottom: 14),
      child: Material(color: Colors.white, borderRadius: BorderRadius.circular(16),
        child: InkWell(onTap: () => _details(service), borderRadius: BorderRadius.circular(16),
          child: Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDCE9F5)), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: text(17, weight: FontWeight.w800)),
                if (description.isNotEmpty) ...[const SizedBox(height: 8),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400))],
                const SizedBox(height: 14),
                Row(children: [Text(t('عرض التفاصيل', 'View details'), style: text(12, color: _blue, weight: FontWeight.w700)),
                  const SizedBox(width: 8), const Icon(Icons.arrow_forward, color: _blue, size: 18)]),
              ])),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: AspectRatio(aspectRatio: 1,
                child: ClipRect(child: Image.asset('lib/assets/services_art.png', fit: BoxFit.cover, alignment: alignment)))),
            ])),
        )));
  }
}

