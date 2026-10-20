import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Api/RequestsApi.dart';
import '../Models/RequestsModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';

typedef OrdersLoader = Future<List<RequestsModel>?> Function(BuildContext context);
const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class RequestsPage extends StatefulWidget {
  final OrdersLoader? loadOrders;
  const RequestsPage({super.key, this.loadOrders});
  @override
  State<RequestsPage> createState() => _OrdersState();
}
class _OrdersState extends State<RequestsPage> {
  final _search = TextEditingController();
  List<RequestsModel> _orders = [];
  bool _loading = true, _failed = false;
  int _filter = 0;
  bool get signedIn => (DelegateData.delegateData?.id ?? -1) > 0;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.5);
  @override
  void initState() { super.initState(); if (signedIn) _load(); else _loading = false; }
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  int _bucket(String? status) {
    final s = (status ?? '').trim().toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (['underexecute', 'pending', 'inprogress', 'processing', 'قيدالتنفيذ', 'تحتالتنفيذ', 'جاريالتنفيذ'].contains(s)) return 1;
    if (['completed', 'complete', 'done', 'finished', 'مكتمل', 'مكتملة', 'تمالتنفيذ', 'منفذ'].contains(s)) return 2;
    return 0;
  }
  String _status(RequestsModel order) => switch (_bucket(order.status)) {
    1 => t('قيد التنفيذ', 'In progress'), 2 => t('مكتمل', 'Completed'),
    _ => (order.status ?? '').trim().isEmpty ? t('غير محدد', 'Unspecified') : order.status!,
  };
  String _digits(String value) => value.split('').map((c) {
    const a = '٠١٢٣٤٥٦٧٨٩', p = '۰۱۲۳۴۵۶۷۸۹';
    return a.contains(c) ? '${a.indexOf(c)}' : p.contains(c) ? '${p.indexOf(c)}' : c;
  }).join();
  String _date(String? value) {
    if ((value ?? '').trim().isEmpty) return '—';
    final date = DateTime.tryParse(value!);
    return date == null ? value : '${date.day}/${date.month}/${date.year}';
  }
  Future<void> _load() async {
    if (!signedIn) return;
    setState(() { _loading = true; _failed = false; });
    try {
      final data = await (widget.loadOrders ?? GetRequests)(context);
      if (!mounted) return;
      setState(() { _failed = data == null; if (data != null) _orders = data; });
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    final query = _digits(_search.text.trim().replaceFirst('#', ''));
    final orders = _orders.where((o) => (query.isEmpty || '${o.id ?? ''}'.contains(query)) &&
      (_filter == 0 || _bucket(o.status) == _filter)).toList();
    final labels = [t('الكل', 'All'), t('قيد التنفيذ', 'In progress'), t('مكتمل', 'Completed')];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0,
          foregroundColor: _ink, centerTitle: true, toolbarHeight: 64,
          title: Text(t('طلباتي', 'My orders'), style: text(22, weight: FontWeight.w800)),
          leading: IconButton(tooltip: t('رجوع', 'Back'), onPressed: () => Navigator.pop(context), icon: const BackButtonIcon()),
          actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 64, height: 48))]),
        body: !signedIn ? _guest() : Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('طلباتك في مكان واحد', 'Your orders in one place'), style: text(24, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(t('استعرض حالة طلبك وتفاصيله', 'View your order status and details'), style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)),
            const SizedBox(height: 20),
            TextField(key: const ValueKey('order-search'), controller: _search, onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.number, style: text(14),
              decoration: InputDecoration(hintText: t('ابحث برقم الطلب', 'Search by order number'),
                hintStyle: text(13, color: const Color(0xFF8293A4)), prefixIcon: const Icon(Icons.search, color: _blue),
                suffixIcon: query.isEmpty ? null : IconButton(tooltip: t('مسح البحث', 'Clear search'),
                  onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close, size: 18)),
                filled: true, fillColor: const Color(0xFFEAF4FD), contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFEAF4FD), borderRadius: BorderRadius.circular(14)),
              child: Row(children: List.generate(3, (index) => Expanded(child: InkWell(
                key: ValueKey('orders-filter-$index'), borderRadius: BorderRadius.circular(11), onTap: () => setState(() => _filter = index),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(color: _filter == index ? _blue : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                  child: Column(children: [Text(labels[index], style: text(12, color: _filter == index ? Colors.white : _blue)),
                    const SizedBox(height: 4), Container(width: 20, height: 3, decoration: BoxDecoration(
                      color: _filter == index ? const Color(0xFFFFCB22) : Colors.transparent, borderRadius: BorderRadius.circular(8)))])),
              ))))),
            const SizedBox(height: 16),
          ])),
          if (_loading) const LinearProgressIndicator(minHeight: 2, color: Color(0xFFFFCB22), backgroundColor: Color(0xFFEAF4FD)),
          Expanded(child: RefreshIndicator(onRefresh: _load, color: _blue,
            child: ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 24), physics: const AlwaysScrollableScrollPhysics(), children: [
              if (_failed) _empty(t('تعذر تحميل الطلبات', 'Could not load orders'), retry: true)
              else if (!_loading && orders.isEmpty) _empty(_orders.isEmpty ? t('لا توجد طلبات حاليًا', 'No orders yet')
                : t('لا توجد طلبات مطابقة', 'No matching orders')),
              for (final order in orders) _card(order),
            ]))),
        ]),
      ),
    );
  }
  Widget _card(RequestsModel order) {
    final pending = _bucket(order.status) == 1;
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(
      key: ValueKey('order-${order.id}'), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD5E5F3)), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const CircleAvatar(radius: 20, backgroundColor: Color(0xFFEAF4FD), child: Icon(Icons.receipt_long_outlined, color: _blue, size: 23)),
          const SizedBox(width: 10), Expanded(child: Text('${t('طلب', 'Order')} #${order.id ?? '—'}', style: text(17, weight: FontWeight.w800))),
          Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: pending ? const Color(0xFFE2F0FD) : const Color(0xFFF0F3F6), borderRadius: BorderRadius.circular(20)),
            child: Text(_status(order), maxLines: 2, overflow: TextOverflow.ellipsis, style: text(11, color: pending ? _blue : _ink)))),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('إجمالي الطلب', 'Order total'), style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
            const SizedBox(height: 5), Text('${order.totalCost ?? '—'} ${t('ر.س', 'SAR')}', style: text(21, weight: FontWeight.w800)),
          ])),
          const SizedBox(width: 12),
          Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 16),
            const SizedBox(width: 6), Flexible(child: Text(_date(order.date), style: text(11, color: const Color(0xFF64748B), weight: FontWeight.w400)))])),
        ]),
        const SizedBox(height: 14), const Divider(height: 1, color: Color(0xFFE1EBF4)),
        TextButton(onPressed: () => Navigator.pushNamed(context, RequestsDetailsRoute, arguments: order),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), alignment: AlignmentDirectional.centerStart),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text(t('عرض التفاصيل', 'View details'), style: text(13, color: _blue, weight: FontWeight.w700)),
            const SizedBox(width: 10), const Icon(Icons.arrow_forward, color: _blue, size: 22)])),
      ])));
  }
  Widget _empty(String label, {bool retry = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(children: [const Icon(Icons.receipt_long_outlined, color: _blue, size: 44), const SizedBox(height: 14),
      Text(label, style: text(15)), if (retry) TextButton(onPressed: _load, child: Text(t('حاول مجددًا', 'Retry')))]));
  Widget _guest() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.lock_outline, color: _blue, size: 46), const SizedBox(height: 14),
    Text(t('سجّل الدخول لعرض طلباتك', 'Sign in to view your orders'), style: text(16)), const SizedBox(height: 18),
    FilledButton(onPressed: () => Navigator.pushNamed(context, loginRoute), style: FilledButton.styleFrom(backgroundColor: _blue),
      child: Text(t('تسجيل الدخول', 'Sign in'), style: text(13, color: Colors.white))),
  ]));
}
