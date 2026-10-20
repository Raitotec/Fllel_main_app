import 'package:flutter/material.dart';
import '../../Shared_Data/LanguageData.dart';

String authText(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
const authBlue = Color(0xFF1C6096);
const authInk = Color(0xFF123D63);
class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.title, required this.subtitle, required this.formKey, required this.children, required this.loading, this.compact = false});
  final String title, subtitle;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final bool loading, compact;
  @override
  Widget build(BuildContext context) => Theme(data: Theme.of(context).copyWith(
    textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Cairo', bodyColor: authInk, displayColor: authInk),
    colorScheme: ColorScheme.fromSeed(seedColor: authBlue)), child: Scaffold(backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, foregroundColor: authInk, elevation: 0),
    body: SafeArea(child: AbsorbPointer(absorbing: loading, child: Form(key: formKey,
      child: ListView(padding: const EdgeInsets.fromLTRB(22, 4, 22, 24), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
        Center(child: Container(width: compact ? 105 : 175, height: compact ? 105 : 175,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEAF4FB), width: 12)),
          child: ClipOval(child: ColoredBox(color: Colors.white, child: Padding(padding: const EdgeInsets.all(10), child: Image.asset('lib/assets/fal_brand.png')))))),
        const SizedBox(height: 18), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 26, fontWeight: FontWeight.w800, color: authInk)),
        const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.7, color: Color(0xFF64748B))),
        const SizedBox(height: 26), ...children,
        if (loading) const Padding(padding: EdgeInsets.all(14), child: Center(child: CircularProgressIndicator(color: authBlue))),
      ]))))));
}
class AuthField extends StatefulWidget {
  const AuthField({super.key, required this.controller, required this.label, required this.icon, this.password = false, this.keyboard, this.autofill, this.validator});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool password;
  final TextInputType? keyboard;
  final List<String>? autofill;
  final String? Function(String?)? validator;
  @override
  State<AuthField> createState() => _AuthFieldState();
}
class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
    controller: widget.controller, obscureText: widget.password && _hidden, enableSuggestions: !widget.password, autocorrect: !widget.password,
    keyboardType: widget.keyboard, autofillHints: widget.autofill, textInputAction: TextInputAction.next,
    textDirection: widget.password || widget.keyboard == TextInputType.emailAddress || widget.keyboard == TextInputType.phone ? TextDirection.ltr : null,
    validator: widget.validator, decoration: InputDecoration(labelText: widget.label, prefixIcon: Icon(widget.icon, color: authBlue),
      suffixIcon: widget.password ? IconButton(tooltip: authText(_hidden ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور', _hidden ? 'Show password' : 'Hide password'),
        onPressed: () => setState(() => _hidden = !_hidden), icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined)) : null,
      filled: true, fillColor: const Color(0xFFFAFCFE),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD2DFEA))),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))));
}
Widget authButton(String text, VoidCallback? action) => FilledButton(onPressed: action,
  style: FilledButton.styleFrom(backgroundColor: authBlue, minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
  child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)));
