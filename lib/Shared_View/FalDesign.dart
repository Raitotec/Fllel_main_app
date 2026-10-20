import 'package:flutter/material.dart';
import '../Shared_Data/LanguageData.dart';

const falBlue = Color(0xFF1C6096), falInk = Color(0xFF123D63), falGold = Color(0xFFFFCB22);
String falText(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
TextStyle falStyle(double size, {FontWeight weight = FontWeight.w600, Color color = falInk}) => TextStyle(fontFamily: 'Cairo', fontSize: size, fontWeight: weight, color: color, height: 1.7);
class FalPage extends StatelessWidget {
  const FalPage({super.key, required this.title, required this.body, this.bottom, this.loading = false});
  final String title;
  final Widget body;
  final Widget? bottom;
  final bool loading;
  @override
  Widget build(BuildContext context) => Theme(data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Cairo', bodyColor: falInk, displayColor: falInk),
    colorScheme: ColorScheme.fromSeed(seedColor: falBlue),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: falBlue,
      side: const BorderSide(color: Color(0xFFB9D3E9)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFFFAFCFE),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD2DFEA))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: falBlue, width: 2))),
    segmentedButtonTheme: SegmentedButtonThemeData(style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? falBlue : const Color(0xFFF0F6FA)),
      foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : falBlue),
      side: WidgetStateProperty.all(const BorderSide(color: Color(0xFFD2DFEA)))))), child: Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, foregroundColor: falInk, centerTitle: true, elevation: 0,
        title: Text(title, style: falStyle(20, weight: FontWeight.w800)),
        actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 60))]),
      body: SafeArea(child: Stack(children: [AbsorbPointer(absorbing: loading, child: body),
        if (loading) const Positioned.fill(child: ColoredBox(color: Color(0x99FFFFFF), child: Center(child: CircularProgressIndicator(color: falBlue))))])),
      bottomNavigationBar: bottom == null ? null : SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 14), child: bottom))));
}
Widget falButton(String label, VoidCallback? onPressed, {Color color = falBlue}) => FilledButton(onPressed: onPressed,
  style: FilledButton.styleFrom(backgroundColor: color, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  child: Text(label, style: falStyle(14, color: Colors.white, weight: FontWeight.w700)));
Widget falCard(List<Widget> children, {Color color = Colors.white}) => Container(padding: const EdgeInsets.all(18), margin: const EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(color: color, border: Border.all(color: const Color(0xFFD2E3F0)), borderRadius: BorderRadius.circular(16)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
