import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Models/DataModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class NewServicesPage extends StatelessWidget {
  final DataModel data;
  const NewServicesPage({required this.data, super.key});
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.6);
  @override
  Widget build(BuildContext context) {
    final name = data.name ?? '';
    final lower = name.toLowerCase();
    final station = lower.contains('محط') || lower.contains('وقود') || lower.contains('fuel') || lower.contains('station');
    final logistics = lower.contains('لوجست') || lower.contains('جمرك') || lower.contains('نقل') || lower.contains('logist') || lower.contains('transport');
    final alignment = station ? Alignment.centerLeft : logistics ? Alignment.center : Alignment.centerRight;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0,
          foregroundColor: _ink, toolbarHeight: 64,
          title: Text(t('تفاصيل الخدمة', 'Service details'), style: text(19, weight: FontWeight.w800)), centerTitle: true,
          leading: IconButton(tooltip: t('رجوع', 'Back'), onPressed: () => Navigator.pop(context), icon: const BackButtonIcon()),
          actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Image.asset('lib/assets/fal_brand.png', width: 64, height: 48))]),
        body: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
          Container(height: 180, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFEAF4FD), borderRadius: BorderRadius.circular(18)),
            child: Center(child: AspectRatio(aspectRatio: 1,
              child: ClipRect(child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Color(0xFFEAF4FD), BlendMode.multiply),
                child: Image.asset('lib/assets/services_art.png', fit: BoxFit.cover, alignment: alignment)))))),
          const SizedBox(height: 20),
          Align(alignment: AlignmentDirectional.centerStart, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFFF3C3), borderRadius: BorderRadius.circular(8)),
            child: Text(t('خدمات فلل', 'FAL services'), style: text(12)))),
          const SizedBox(height: 8),
          Text(name, style: text(25, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(station ? t('خدمات محطاتنا أقرب إليك', 'Our station services, closer to you')
            : t('حلول متكاملة لرحلتك وأعمالك', 'Solutions for your journey and business'),
            style: text(14, color: _blue)),
          const SizedBox(height: 24),
          Text(t('عن الخدمة', 'About this service'), style: text(19, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Align(alignment: AlignmentDirectional.centerStart, child: Container(width: 30, height: 3,
            decoration: BoxDecoration(color: const Color(0xFFFFCB22), borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 12),
          Text((data.desc ?? '').trim().isEmpty ? t('لا يتوفر وصف لهذه الخدمة حاليًا.', 'No description available for this service yet.')
            : data.desc!, style: text(14, color: const Color(0xFF536476), weight: FontWeight.w400)),
          if (station) ...[
            const SizedBox(height: 22),
            Container(decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDCE9F5)), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _row(context, Icons.location_on_outlined, t('مواقع المحطات', 'Station locations'),
                  t('استعرض المحطات على الخريطة', 'Explore stations on the map')),
                const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFDCE9F5)),
                _row(context, Icons.format_list_bulleted, t('خدمات كل محطة', 'Station services'),
                  t('اختر محطة لمعرفة خدماتها', 'Choose a station to view its services')),
              ])),
          ],
          const SizedBox(height: 20),
          Material(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(14),
            child: InkWell(onTap: () => Navigator.pushNamed(context, Connect_usRoute), borderRadius: BorderRadius.circular(14),
              child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                const Icon(Icons.chat_bubble_outline, color: _blue, size: 27), const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('لديك استفسار؟', 'Have a question?'), style: text(15, weight: FontWeight.w800)),
                  Text(t('تواصل معنا', 'Contact us'), style: text(13, color: _blue)),
                ])), const Icon(Icons.arrow_forward, color: _blue, size: 20),
              ])))),
        ]),
        bottomNavigationBar: SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE6EDF4)))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, station ? station_locationRoute : Connect_usRoute),
              style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: Icon(station ? Icons.arrow_forward : Icons.chat_bubble_outline, size: 21),
              label: Text(station ? t('استعرض المحطات', 'View stations') : t('تواصل معنا', 'Contact us'),
                style: text(15, color: Colors.white, weight: FontWeight.w700)))),
            if (station) Padding(padding: const EdgeInsets.only(top: 6),
              child: Text(t('اختر المحطة المناسبة لزيارتك', 'Find the right station for your visit'),
                style: text(10, color: const Color(0xFF64748B), weight: FontWeight.w400))),
          ]))),
      ),
    );
  }
  Widget _row(BuildContext context, IconData icon, String title, String subtitle) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    leading: CircleAvatar(backgroundColor: const Color(0xFFEAF4FD), child: Icon(icon, color: _blue, size: 23)),
    title: Text(title, style: text(14, weight: FontWeight.w800)),
    subtitle: Text(subtitle, style: text(11, color: const Color(0xFF64748B), weight: FontWeight.w400)),
    trailing: const Icon(Icons.arrow_forward, color: _blue, size: 19),
    onTap: () => Navigator.pushNamed(context, station_locationRoute),
  );
}

