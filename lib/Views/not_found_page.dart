import 'package:flutter/material.dart';
import '../Routes/route_constants.dart';
import '../Shared_View/FalDesign.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => FalPage(title: '', body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(children: [
    Image.asset('lib/assets/fal_brand.png', width: 110), const SizedBox(height: 28),
    Container(width: 160, height: 160, decoration: const BoxDecoration(color: Color(0xFFEEF6FC), shape: BoxShape.circle),
      child: const Stack(alignment: Alignment.center, children: [Icon(Icons.map_outlined, color: falBlue, size: 90), Positioned(right: 16, bottom: 18, child: Icon(Icons.help, color: falGold, size: 45))])),
    const SizedBox(height: 30), Text(falText('الصفحة غير متاحة', 'Page unavailable'), textAlign: TextAlign.center, style: falStyle(25, weight: FontWeight.w800)), const SizedBox(height: 12),
    Text(falText('تعذّر العثور على هذه الصفحة. يمكنك العودة للرئيسية ومتابعة خدماتك.', 'This page could not be found. Return home to continue.'), textAlign: TextAlign.center, style: falStyle(14, weight: FontWeight.w400)),
    const SizedBox(height: 26), falButton(falText('العودة للرئيسية', 'Return home'), () => Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false)),
    if (Navigator.canPop(context)) ...[const SizedBox(height: 12), OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(falText('رجوع', 'Back')))],
  ]))));
}
