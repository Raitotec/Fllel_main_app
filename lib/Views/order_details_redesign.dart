import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Models/RequestsModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class RequestsDetailsPage extends StatelessWidget {
  final RequestsModel obj;
  const RequestsDetailsPage({required this.obj, super.key});
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.5);
  String get status {
    final s = (obj.status ?? '').trim().toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    if (['underexecute', 'pending', 'inprogress', 'processing', 'قيدالتنفيذ', 'تحتالتنفيذ', 'جاريالتنفيذ'].contains(s)) {
      return t('قيد التنفيذ', 'In progress');
    }
    if (['completed', 'complete', 'done', 'finished', 'مكتمل', 'مكتملة', 'تمالتنفيذ', 'منفذ'].contains(s)) {
      return t('مكتمل', 'Completed');
    }
    return (obj.status ?? '').trim().isEmpty ? t('غير محدد', 'Unspecified') : obj.status!;
  }
  String get date {
    if ((obj.date ?? '').trim().isEmpty) return '—';
    final parsed = DateTime.tryParse(obj.date!);
    return parsed == null ? obj.date! : '${parsed.day}/${parsed.month}/${parsed.year}';
  }
  BoxDecoration card() => BoxDecoration(color: Colors.white,
    border: Border.all(color: const Color(0xFFD5E5F3)), borderRadius: BorderRadius.circular(16));
  @override
  Widget build(BuildContext context) {
    final items = obj.details ?? <RequestsDetails>[];
    final qr = obj.url ?? '';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0, foregroundColor: _ink,
          centerTitle: true, toolbarHeight: 64,
          leading: IconButton(tooltip: t('رجوع', 'Back'), onPressed: () => Navigator.pop(context), icon: const BackButtonIcon()),
          title: Text(t('تفاصيل الطلب', 'Order details'), style: text(21, weight: FontWeight.w800)),
          actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 64, height: 48))]),
        body: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: [
          Container(padding: const EdgeInsets.all(18), decoration: card(), child: Column(children: [
            Row(children: [const Icon(Icons.receipt_long_outlined, color: _blue, size: 30), const SizedBox(width: 10),
              Expanded(child: Text('${t('طلب', 'Order')} #${obj.id ?? '—'}', style: text(21, weight: FontWeight.w800))),
              Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: const Color(0xFFEAF4FD), borderRadius: BorderRadius.circular(20)),
                child: Text(status, maxLines: 2, overflow: TextOverflow.ellipsis, style: text(12, color: _blue)))),
            ]),
            const SizedBox(height: 16),
            Row(children: [const Icon(Icons.calendar_today_outlined, color: _blue, size: 21), const SizedBox(width: 10),
              Expanded(child: Text(date, style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)))]),
          ])),
          const SizedBox(height: 24),
          Text(t('عناصر الطلب', 'Order items'), style: text(21, weight: FontWeight.w800)), const SizedBox(height: 5),
          Align(alignment: AlignmentDirectional.centerStart, child: Container(width: 32, height: 3, color: const Color(0xFFFFCB22))),
          const SizedBox(height: 14),
          Container(decoration: card(), child: Column(children: [
            if (items.isEmpty) Padding(padding: const EdgeInsets.all(24),
              child: Text(t('لا توجد تفاصيل متاحة للطلب', 'No item details available'), style: text(13, color: const Color(0xFF64748B)))),
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFE1EBF4)),
              _item(items[i]),
            ],
            Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEAF4FD), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [Expanded(child: Text(t('إجمالي الطلب', 'Order total'), style: text(15, weight: FontWeight.w800))),
                const SizedBox(width: 10), Flexible(child: _money(obj.totalCost, 23))])),
          ])),
          if ((obj.address ?? '').trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 18),
            child: Container(padding: const EdgeInsets.all(16), decoration: card(),
              child: Row(children: [const Icon(Icons.location_on_outlined, color: _blue), const SizedBox(width: 10),
                Expanded(child: Text(obj.address!, style: text(12, color: const Color(0xFF64748B))))]))),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(20), decoration: card(), child: Column(children: [
            Text(t('رمز الطلب', 'Order code'), style: text(20, weight: FontWeight.w800)), const SizedBox(height: 6),
            Text(t('اعرض الرمز عند مراجعة طلبك', 'Show the code when reviewing your order'), textAlign: TextAlign.center,
              style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)), const SizedBox(height: 18),
            if (qr.trim().isNotEmpty) LayoutBuilder(builder: (context, constraints) => QrImageView(
              data: qr, size: constraints.maxWidth.clamp(140.0, 230.0), backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16), errorCorrectionLevel: QrErrorCorrectLevel.M,
              errorStateBuilder: (_, __) => _missingCode()))
            else _missingCode(),
          ])),
          const SizedBox(height: 16),
          Material(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(14),
            child: InkWell(onTap: () => Navigator.pushNamed(context, Connect_usRoute), borderRadius: BorderRadius.circular(14),
              child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                const Icon(Icons.support_agent, color: _blue, size: 27), const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('لديك استفسار عن طلبك؟', 'Have a question about this order?'), style: text(14, weight: FontWeight.w700)),
                  Text(t('تواصل معنا', 'Contact us'), style: text(12, color: _blue)),
                ])), const Icon(Icons.arrow_forward, color: _blue, size: 20),
              ])))),
        ]),
      ),
    );
  }
  Widget _item(RequestsDetails item) => Padding(padding: const EdgeInsets.all(16),
    child: Row(children: [const Icon(Icons.inventory_2_outlined, color: _blue, size: 28), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.productName ?? '—', style: text(15, weight: FontWeight.w700)), const SizedBox(height: 5),
        Text('${t('الكمية', 'Quantity')}: ${item.quantity ?? '—'}', style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
      ])), const SizedBox(width: 10),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(t('سعر الخدمة', 'Service price'), style: text(10, color: const Color(0xFF64748B), weight: FontWeight.w400)),
        _money(item.cost, 17),
      ])),
    ]));
  Widget _money(String? value, double size) => FittedBox(fit: BoxFit.scaleDown,
    child: Row(mainAxisSize: MainAxisSize.min, children: [Text(value ?? '—', textDirection: TextDirection.ltr,
      style: text(size, weight: FontWeight.w800)), const SizedBox(width: 5),
      Text(t('ر.س', 'SAR'), style: text(size * .65, weight: FontWeight.w700))]));
  Widget _missingCode() => Padding(padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(children: [const Icon(Icons.qr_code_2, size: 44, color: Color(0xFF8293A4)), const SizedBox(height: 12),
      Text(t('رمز الطلب غير متاح حاليًا', 'Order code is not available'), style: text(13, color: const Color(0xFF64748B)))]));
}
