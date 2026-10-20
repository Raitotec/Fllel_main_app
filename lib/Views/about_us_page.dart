import 'package:flutter/material.dart';
import '../Api/DataApi.dart';
import '../Models/AboutModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key, this.loadContent});
  final Future<List<AboutModel>?> Function(BuildContext)? loadContent;
  @override
  State<AboutUsPage> createState() => _AboutState();
}
class _AboutState extends State<AboutUsPage> {
  List<AboutModel>? _data;
  bool _loading = true;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _load(); });
  }
  Future<void> _load() async {
    setState(() => _loading = true);
    List<AboutModel>? result;
    try { result = await (widget.loadContent ?? About_us)(context); } catch (_) { result = null; }
    if (mounted) setState(() { _loading = false; _data = result; });
  }
  TextStyle text(double size, {FontWeight weight = FontWeight.w600}) => TextStyle(fontFamily: 'Cairo', fontSize: size, fontWeight: weight, color: const Color(0xFF123D63), height: 1.8);
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, foregroundColor: const Color(0xFF123D63), elevation: 0, centerTitle: true,
      title: Text(t('من نحن', 'About us'), style: text(21, weight: FontWeight.w800)),
      actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 60))]),
    body: SafeArea(child: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(20), physics: const AlwaysScrollableScrollPhysics(), children: [
      Container(height: 190, decoration: BoxDecoration(color: const Color(0xFFEEF6FC), borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias, child: Stack(children: [
          Positioned(left: -50, top: -65, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFCB22), width: 4)))),
          Positioned(right: -70, bottom: -80, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFCB22), width: 4)))),
          Center(child: ColorFiltered(colorFilter: const ColorFilter.mode(Color(0xFFEEF6FC), BlendMode.multiply), child: Image.asset('lib/assets/fal_brand.png', width: 170))),
        ])),
      const SizedBox(height: 18), Text(t('فلل، أقرب لك', 'FAL, closer to you'), textAlign: TextAlign.center, style: text(27, weight: FontWeight.w800)),
      const SizedBox(height: 6), Center(child: Container(width: 40, height: 4, color: const Color(0xFFFFCB22))), const SizedBox(height: 24),
      if (_loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: Color(0xFF1C6096))))
      else if (_data == null) Column(children: [Text(t('تعذّر تحميل المعلومات', 'Unable to load information'), style: text(15)),
        TextButton(onPressed: _load, child: Text(t('إعادة المحاولة', 'Try again')))])
      else if (_data!.isEmpty) Text(t('لا توجد معلومات متاحة حاليًا', 'No information is currently available'), style: text(15))
      else for (final section in _data!) Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD2E3F0)), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if ((section.name ?? '').isNotEmpty) Row(children: [Container(width: 4, height: 25, color: const Color(0xFFFFCB22)), const SizedBox(width: 10),
            Expanded(child: Text(section.name!, style: text(19, weight: FontWeight.w800)))]),
          if ((section.description ?? '').isNotEmpty) ...[const SizedBox(height: 12), Text(section.description!, style: text(14, weight: FontWeight.w400))],
        ])),
      const SizedBox(height: 10), FilledButton.icon(onPressed: () => Navigator.pushNamed(context, Connect_usRoute),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1C6096), padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        icon: const Icon(Icons.chat_bubble_outline), label: Text(t('تواصل معنا', 'Contact us'), style: text(14).copyWith(color: Colors.white))),
    ]))));
}

