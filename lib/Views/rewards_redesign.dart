import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Api/DataApi.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/BalancePointData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/QrEncryption.dart';
import '../Shared_View/DrawerView.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class LoyaltySystemPage extends StatefulWidget {
  final bool embedded;
  const LoyaltySystemPage({super.key, this.embedded = false});
  @override
  State<LoyaltySystemPage> createState() => _RewardsState();
}
class _RewardsState extends State<LoyaltySystemPage> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _expires;
  String? _qr;
  int _seconds = 0;
  bool _loading = false, _failed = false, _expired = false;
  String? _qrError;
  bool get signedIn => (DelegateData.delegateData?.id ?? -1) > 0;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.5);
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); if (signedIn) _refresh(); }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); _timer?.cancel(); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && signedIn) { _tick(); _refresh(); }
  }
  Future<void> _refresh() async {
    if (!signedIn || _loading) return;
    setState(() { _loading = true; _failed = false; });
    try {
      final data = await AppMainPageFun(context);
      if (!mounted) return;
      setState(() {
        _failed = data == null;
        if (data != null) { BalancePointData.Point = data.pointsBalance ?? '';
          BalancePointData.Balance = data.walletBalance ?? ''; }
      });
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _signIn() async {
    await Navigator.pushNamed(context, loginRoute);
    if (mounted) { setState(() {}); if (signedIn) _refresh(); }
  }
  void _generate() {
    if (!signedIn) { _signIn(); return; }
    final user = DelegateData.delegateData!;
    final points = BalancePointData.Point;
    if (_loading || _failed || points.isEmpty) return;
    try {
      final qr = QrEncryption.encrypt(userId: user.id!, points: points,
        userName: user.name ?? '', userPhone: user.mobile ?? '', userEmail: user.email ?? '');
      _timer?.cancel();
      setState(() { _qr = qr; _expires = DateTime.now().add(const Duration(seconds: 20));
        _seconds = 20; _expired = false; _qrError = null; });
      _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    } catch (_) {
      setState(() => _qrError = t('تعذر إنشاء رمز الاستبدال. يرجى التواصل مع الدعم.',
        'Could not generate a redemption code. Please contact support.'));
    }
  }
  void _tick() {
    if (!mounted || _expires == null) return;
    final seconds = (_expires!.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    if (seconds <= 0) {
      _timer?.cancel();
      setState(() { _qr = null; _expires = null; _seconds = 0; _expired = true; });
      _refresh();
    } else if (_seconds != seconds) { setState(() => _seconds = seconds); }
  }
  @override
  Widget build(BuildContext context) {
    final points = BalancePointData.Point;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white, drawer: DrawerList(context),
        body: SafeArea(top: !widget.embedded, child: RefreshIndicator(color: _blue, onRefresh: _refresh,
          child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 22), children: [
            Row(children: [Image.asset('lib/assets/fal_brand.png', width: 70, height: 56),
              Expanded(child: Center(child: Text(t('المكافآت', 'Rewards'), style: text(22, weight: FontWeight.w800)))),
              if (!widget.embedded) IconButton(tooltip: t('رجوع', 'Back'), onPressed: () => Navigator.pop(context), icon: const BackButtonIcon())
              else Builder(builder: (context) => IconButton(tooltip: t('القائمة', 'Menu'),
                onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.person_outline, color: _blue))),
            ]),
            const SizedBox(height: 18),
            Text(t('نقاطك مع فلل', 'Your FAL points'), textAlign: TextAlign.center, style: text(27, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(t('استعرض رصيدك واستبدل نقاطك', 'View and redeem your points'), textAlign: TextAlign.center,
              style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('رصيد النقاط', 'Points balance'), style: text(14, color: Colors.white)), const SizedBox(height: 8),
                Text(signedIn && points.isNotEmpty ? points : '—', textDirection: TextDirection.ltr,
                  style: text(38, color: Colors.white, weight: FontWeight.w800)),
                Text(signedIn ? t('نقطة', 'points') : t('سجّل الدخول لعرض رصيدك', 'Sign in to view your balance'),
                  style: text(12, color: Colors.white)),
              ])), const Icon(Icons.star_outline_rounded, color: Color(0xFFFFCB22), size: 65)])),
            if (_loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(
              color: Color(0xFFFFCB22), backgroundColor: Color(0xFFEAF4FD), minHeight: 2)),
            if (_failed) Row(children: [Expanded(child: Text(t('تعذر تحديث الرصيد', 'Could not refresh balance'), style: text(12))),
              TextButton(onPressed: _refresh, child: Text(t('حاول مجددًا', 'Retry')))]),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8E6F2)), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Row(children: [const Icon(Icons.qr_code_2, color: Color(0xFFFFCB22), size: 28), const SizedBox(width: 10),
                  Expanded(child: Text(t('استبدال النقاط', 'Redeem points'), style: text(20, weight: FontWeight.w800)))]),
                const SizedBox(height: 8),
                Text(signedIn ? t('أظهر الرمز للموظف عند الاستبدال', 'Show the code to staff when redeeming')
                  : t('سجّل الدخول للوصول إلى مكافآتك', 'Sign in to access your rewards'),
                  textAlign: TextAlign.center, style: text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
                const SizedBox(height: 18),
                if (_qr != null) QrImageView(data: _qr!, size: 210, backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(16), errorCorrectionLevel: QrErrorCorrectLevel.M)
                else Container(height: 150, width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFFF5F9FD), borderRadius: BorderRadius.circular(14)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(signedIn ? Icons.qr_code_2 : Icons.lock_outline, size: 52, color: _blue), const SizedBox(height: 10),
                    Text(_expired ? t('انتهت صلاحية الرمز', 'Code expired') : t('سيظهر الرمز هنا', 'Your code will appear here'), style: text(12)),
                  ])),
                const SizedBox(height: 16),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFEAF4FD), borderRadius: BorderRadius.circular(30)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.access_time, color: _blue, size: 19),
                    const SizedBox(width: 8), Text(_qr == null ? t('صلاحية الرمز: 20 ثانية', 'Code validity: 20 seconds')
                      : '${t('الوقت المتبقي', 'Time remaining')}: $_seconds ${t('ثانية', 'seconds')}', style: text(12, color: _blue))])),
                if (_qrError != null) Padding(padding: const EdgeInsets.only(top: 12),
                  child: Text(_qrError!, textAlign: TextAlign.center, style: text(12, color: const Color(0xFFB42318)))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: !signedIn ? _signIn
                  : _loading || _failed || points.isEmpty || _qr != null ? null : _generate,
                  style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(!signedIn ? t('تسجيل الدخول', 'Sign in') : _expired ? t('تجديد رمز الاستبدال', 'Generate a new code')
                    : t('عرض رمز الاستبدال', 'Show redemption code'), style: text(14, color: Colors.white, weight: FontWeight.w700)))),
              ])),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [const Icon(Icons.info_outline, color: _blue, size: 22), const SizedBox(width: 10),
                Expanded(child: Text(t('يتجدد الرمز عند إعادة طلبه', 'A new code is generated when requested again'), style: text(11, color: _blue)))])),
            const SizedBox(height: 12),
            ListTile(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFDCE9F5))),
              leading: const Icon(Icons.support_agent, color: _blue), title: Text(t('تحتاج مساعدة؟', 'Need help?'), style: text(13)),
              subtitle: Text(t('تواصل معنا', 'Contact us'), style: text(12, color: _blue)), trailing: const Icon(Icons.arrow_forward, color: _blue),
              onTap: () => Navigator.pushNamed(context, Connect_usRoute)),
          ]))),
      ),
    );
  }
}

