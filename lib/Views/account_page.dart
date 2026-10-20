import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../Localization/ScopeModelWrapper.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountState();
}
class _AccountState extends State<AccountPage> {
  final _settingsKey = GlobalKey();
  bool _signingOut = false;
  bool get signedIn => (DelegateData.delegateData?.id ?? -1) > 0;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.5);
  Future<void> _open(String route, {bool requiresLogin = false}) async {
    if (requiresLogin && !signedIn) {
      await Navigator.pushNamed(context, loginRoute);
      if (!mounted) return;
      setState(() {});
      if (!signedIn) return;
    }
    if (!mounted) return;
    await Navigator.pushNamed(context, route);
    if (mounted) setState(() {});
  }
  Future<void> _language() async {
    final model = ScopedModel.of<AppModel>(context);
    final selected = await showModalBottomSheet<String>(context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t('اختر اللغة', 'Choose language'), style: text(20, weight: FontWeight.w800)),
          const SizedBox(height: 14),
          ListTile(title: Text('العربية', style: text(16)),
            trailing: LanguageData.languageData == 'ar' ? const Icon(Icons.check, color: _blue) : null,
            onTap: () => Navigator.pop(context, 'ar')),
          ListTile(title: Text('English', style: text(16)),
            trailing: LanguageData.languageData == 'en' ? const Icon(Icons.check, color: _blue) : null,
            onTap: () => Navigator.pop(context, 'en')),
        ]))));
    if (!mounted || selected == null || model.appLocal.languageCode == selected) return;
    model.changeDirection();
    LanguageData.languageData = selected;
    setState(() {});
  }
  Future<void> _logout() async {
    if (_signingOut) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(t('تسجيل الخروج', 'Sign out'), style: text(19, weight: FontWeight.w800)),
      content: Text(t('هل تريد تسجيل الخروج من حسابك؟', 'Do you want to sign out of your account?'), style: text(14)),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('إلغاء', 'Cancel'))),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t('تسجيل الخروج', 'Sign out'),
          style: text(13, color: const Color(0xFFB42318))))]));
    if (!mounted || confirmed != true) return;
    setState(() => _signingOut = true);
    await removeDelgateDate();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false);
  }
  @override
  Widget build(BuildContext context) {
    final name = (DelegateData.delegateData?.name ?? '').trim();
    return Scaffold(backgroundColor: Colors.white,
      body: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 22), children: [
        Row(children: [Image.asset('lib/assets/fal_brand.png', width: 76, height: 58),
          Expanded(child: Center(child: Text(t('حسابي', 'Account'), style: text(24, weight: FontWeight.w800)))),
          IconButton(tooltip: t('الإعدادات والمساعدة', 'Settings and help'),
            onPressed: () { final target = _settingsKey.currentContext;
              if (target != null) Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 250)); },
            icon: const Icon(Icons.settings_outlined, color: _blue)),
        ]),
        const SizedBox(height: 18),
        Material(color: const Color(0xFFEEF6FD), borderRadius: BorderRadius.circular(16),
          child: InkWell(onTap: () => _open(signedIn ? PersonInformationRoute : loginRoute),
            borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD8E7F5)), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(width: 62, height: 62, decoration: BoxDecoration(color: Colors.white,
                  shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFCB22), width: 2)),
                  child: const Icon(Icons.person_outline, color: _blue, size: 38)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(signedIn ? '${t('أهلاً', 'Hello')}${name.isEmpty ? '' : '، $name'}' : t('أهلاً بك', 'Welcome'),
                    style: text(20, weight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(signedIn ? t('حسابك مع فلل', 'Your FAL account') : t('سجّل الدخول لإدارة حسابك', 'Sign in to manage your account'),
                    style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
                ])), const Icon(Icons.edit_outlined, color: _blue, size: 22),
              ])))),
        const SizedBox(height: 20),
        _group(t('حسابك', 'Your account'), [
          _row(Icons.person_outline, t('معلوماتي', 'My information'), () => _open(PersonInformationRoute, requiresLogin: true)),
          _row(Icons.account_balance_wallet_outlined, t('المحفظة', 'Wallet'), () => _open(BalanceRoute, requiresLogin: true)),
          _row(Icons.receipt_long_outlined, t('طلباتي', 'My orders'), () => _open(RequestsRoute, requiresLogin: true)),
        ]),
        const SizedBox(height: 18),
        Container(key: _settingsKey, child: _group(t('الإعدادات والمساعدة', 'Settings and help'), [
          _row(Icons.language, t('اللغة', 'Language'), _language, subtitle: t('العربية', 'English')),
          _row(Icons.chat_bubble_outline, t('تواصل معنا', 'Contact us'), () => _open(Connect_usRoute)),
          _row(Icons.info_outline, t('من نحن', 'About us'), () => _open(AboutUsRoute)),
          if (signedIn) _row(Icons.delete_outline, t('حذف الحساب', 'Delete account'),
            () => _open(deleteAccountRoute, requiresLogin: true), danger: true),
        ])),
        const SizedBox(height: 20),
        OutlinedButton.icon(onPressed: _signingOut ? null : signedIn ? _logout : () => _open(loginRoute),
          style: OutlinedButton.styleFrom(foregroundColor: signedIn ? const Color(0xFFB42318) : _blue,
            side: BorderSide(color: signedIn ? const Color(0xFFE5A3A3) : const Color(0xFFB9D3E9)),
            padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: Icon(signedIn ? Icons.logout : Icons.login, size: 22),
          label: Text(signedIn ? t('تسجيل الخروج', 'Sign out') : t('تسجيل الدخول', 'Sign in'),
            style: text(14, color: signedIn ? const Color(0xFFB42318) : _blue))),
      ]));
  }
  Widget _group(String title, List<Widget> rows) => Container(
    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDCE9F5)), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFFF4F8FC), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Text(title, style: text(15, weight: FontWeight.w800))),
      for (int i = 0; i < rows.length; i++) ...[
        if (i > 0) const Divider(height: 1, color: Color(0xFFE6EDF4), indent: 16, endIndent: 16), rows[i],
      ],
    ]));
  Widget _row(IconData icon, String label, VoidCallback onTap, {String? subtitle, bool danger = false}) =>
    ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Icon(icon, size: 26, color: danger ? const Color(0xFFB42318) : _blue),
      title: Text(label, style: text(14, color: danger ? const Color(0xFFB42318) : _ink)),
      subtitle: subtitle == null ? null : Text(subtitle, style: text(11, color: const Color(0xFF64748B), weight: FontWeight.w400)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Color(0xFF7A8CA0)), onTap: onTap,
    );
}

