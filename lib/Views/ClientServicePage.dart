import 'package:flutter/material.dart';
import '../Api/SetvicesApi.dart';
import '../Models/ServicesModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/FalDesign.dart';

class ClientServicePage extends StatefulWidget {
  const ClientServicePage({super.key, this.loadServices});
  final Future<List<ServicesModel>?> Function(BuildContext, String)? loadServices;
  @override
  State<ClientServicePage> createState() => _CatalogState();
}
class _CatalogState extends State<ClientServicePage> {
  List<ServicesModel>? _data;
  bool _loading = true;
  final _search = TextEditingController();
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _load(); }); }
  Future<void> _load() async {
    setState(() => _loading = true);
    List<ServicesModel>? result;
    try { result = await (widget.loadServices ?? GetAllServices)(context, ''); } catch (_) { result = null; }
    if (mounted) setState(() { _data = result; _loading = false; });
  }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final visible = (_data ?? <ServicesModel>[]).where((item) => (item.name ?? '').toLowerCase().contains(_search.text.trim().toLowerCase())).toList();
    return FalPage(title: falText('طلب خدمة', 'Request a service'), loading: _loading,
      body: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(), children: [
        Text(falText('اختر الخدمة المناسبة', 'Choose your service'), style: falStyle(24, weight: FontWeight.w800)), const SizedBox(height: 20),
        TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: falText('ابحث عن خدمة', 'Search services'), prefixIcon: const Icon(Icons.search, color: falBlue),
          suffixIcon: _search.text.isEmpty ? null : IconButton(tooltip: falText('مسح البحث', 'Clear search'), onPressed: () => setState(() => _search.clear()), icon: const Icon(Icons.close)))),
        const SizedBox(height: 24),
        if (_data == null && !_loading) ...[Text(falText('تعذّر تحميل الخدمات', 'Unable to load services'), style: falStyle(15)), TextButton(onPressed: _load, child: Text(falText('إعادة المحاولة', 'Try again')))]
        else if (visible.isEmpty && !_loading) Text(falText('لا توجد خدمات مطابقة', 'No matching services'), style: falStyle(15)),
        for (final service in visible) Padding(padding: const EdgeInsets.only(bottom: 16), child: Material(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFD2E3F0))),
          child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () {
            for (final item in _data!) { item.selected = identical(item, service); item.type = '0'; }
            ServicesData.serviceData = _data;
            Navigator.pushNamed(context, serviceDetailsRoute, arguments: _data);
          }, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
            Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFEEF6FC), borderRadius: BorderRadius.circular(12)),
              child: Icon((service.name ?? '').contains('وقود') ? Icons.local_gas_station_outlined : (service.name ?? '').contains('لوجست') ? Icons.local_shipping_outlined : Icons.handyman_outlined, color: falBlue, size: 36)),
            const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(service.name ?? '', style: falStyle(17, weight: FontWeight.w800)),
              const SizedBox(height: 6), Text(falText('استعرض الخيارات المتاحة', 'Browse available options'), style: falStyle(12, weight: FontWeight.w400))])), const SizedBox(width: 6), const Icon(Icons.arrow_forward_ios, size: 16, color: falBlue),
          ]))))),
      ])));
  }
}
