import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Api/BalancePointApi.dart';
import '../Api/DataApi.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/BalancePointData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';

typedef WalletSubmit = Future<bool?> Function(BuildContext context, String description, String amount);
typedef WalletBalanceLoader = Future<String?> Function(BuildContext context);
const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class BalancePage extends StatefulWidget {
  final WalletSubmit? submitRequest;
  final WalletBalanceLoader? loadBalance;
  const BalancePage({super.key, this.submitRequest, this.loadBalance});
  @override
  State<BalancePage> createState() => _WalletState();
}
class _WalletState extends State<BalancePage> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController(), _notes = TextEditingController();
  bool _sending = false, _loading = false, _failed = false, _sent = false;
  String? _sendError;
  bool get signedIn => (DelegateData.delegateData?.id ?? -1) > 0;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.55);
  @override
  void initState() { super.initState(); if (signedIn) _refresh(); }
  @override
  void dispose() { _amount.dispose(); _notes.dispose(); super.dispose(); }
  Future<void> _refresh() async {
    if (!signedIn || _loading) return;
    setState(() { _loading = true; _failed = false; });
    try {
      final String? balance;
      if (widget.loadBalance != null) { balance = await widget.loadBalance!(context); }
      else { final data = await AppMainPageFun(context); balance = data?.walletBalance; }
      if (!mounted) return;
      setState(() { _failed = balance == null; if (balance != null) BalancePointData.Balance = balance; });
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  String _normalize(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩', persian = '۰۱۲۳۴۵۶۷۸۹';
    return value.trim().split('').map((c) {
      final a = arabic.indexOf(c), p = persian.indexOf(c);
      return a >= 0 ? '$a' : p >= 0 ? '$p' : c == '٫' ? '.' : c;
    }).join();
  }
  String? _validateAmount(String? value) {
    final normalized = _normalize(value ?? '');
    final number = double.tryParse(normalized);
    return !RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized) || number == null || !number.isFinite || number <= 0
      ? t('أدخل مبلغًا صحيحًا أكبر من صفر، بمنزلتين عشريتين كحد أقصى', 'Enter a positive amount with up to two decimal places') : null;
  }
  Future<void> _send() async {
    if (_sending || !signedIn || _form.currentState?.validate() != true) return;
    FocusScope.of(context).unfocus();
    setState(() { _sending = true; _sent = false; _sendError = null; });
    try {
      final result = await (widget.submitRequest ?? WalletRequestFun)(context, _notes.text.trim(), _normalize(_amount.text));
      if (!mounted) return;
      if (result == true) {
        _amount.clear(); _notes.clear();
        setState(() => _sent = true);
        await _refresh();
      } else { setState(() => _sendError = t('لم يتم إرسال الطلب. حاول مجددًا.', 'The request was not sent. Please try again.')); }
    } catch (_) {
      if (mounted) setState(() => _sendError = t('تعذر إرسال الطلب. حاول مجددًا.', 'Could not send the request. Please try again.'));
    } finally { if (mounted) setState(() => _sending = false); }
  }
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
    child: Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0,
        foregroundColor: _ink, centerTitle: true, toolbarHeight: 64,
        leading: IconButton(tooltip: t('رجوع', 'Back'), onPressed: _sending ? null : () => Navigator.pop(context), icon: const BackButtonIcon()),
        title: Text(t('المحفظة', 'Wallet'), style: text(22, weight: FontWeight.w800)),
        actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 64, height: 48))]),
      body: RefreshIndicator(onRefresh: _refresh, color: _blue,
        child: Form(key: _form, child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('رصيد المحفظة', 'Wallet balance'), style: text(15, color: Colors.white)), const SizedBox(height: 10),
              Text(signedIn && BalancePointData.Balance.isNotEmpty ? BalancePointData.Balance : '—',
                textDirection: TextDirection.ltr, style: text(36, color: Colors.white, weight: FontWeight.w800)),
              Text(signedIn ? t('ر.س', 'SAR') : t('سجّل الدخول لعرض رصيدك', 'Sign in to view your balance'), style: text(12, color: Colors.white)),
            ])), const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFFCB22), size: 60)])),
          if (_loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2,
            color: Color(0xFFFFCB22), backgroundColor: Color(0xFFEAF4FD))),
          if (_failed) Row(children: [Expanded(child: Text(t('تعذر تحديث الرصيد', 'Could not refresh the balance'), style: text(12))),
            TextButton(onPressed: _refresh, child: Text(t('حاول مجددًا', 'Retry')))]),
          const SizedBox(height: 24),
          Text(t('طلب شحن المحفظة', 'Request wallet funding'), style: text(21, weight: FontWeight.w800)),
          const SizedBox(height: 5),
          Align(alignment: AlignmentDirectional.centerStart, child: Container(width: 32, height: 3, color: const Color(0xFFFFCB22))),
          const SizedBox(height: 12),
          Text(signedIn ? t('أرسل طلب الشحن ليتم مراجعته من فريق الدعم.', 'Send a funding request for our support team to review.')
            : t('سجّل الدخول لإرسال طلب شحن المحفظة.', 'Sign in to request wallet funding.'),
            style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)),
          const SizedBox(height: 22),
          if (signedIn) ...[
            if (_sent) Container(margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFEBF7EF), borderRadius: BorderRadius.circular(12)),
              child: Text(t('تم إرسال طلب الشحن للمراجعة.', 'Funding request submitted for review.'),
                style: text(13, color: const Color(0xFF246B42)))),
            Text(t('المبلغ', 'Amount'), style: text(14, weight: FontWeight.w700)), const SizedBox(height: 8),
            TextFormField(key: const ValueKey('wallet-amount'), controller: _amount, enabled: !_sending,
              keyboardType: const TextInputType.numberWithOptions(decimal: true), textDirection: TextDirection.ltr,
              style: text(15), validator: _validateAmount,
              decoration: _decoration(t('أدخل المبلغ', 'Enter amount'), Icons.payments_outlined,
                suffix: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(t('ر.س', 'SAR'), style: text(13))))),
            const SizedBox(height: 20),
            Text(t('وصف الطلب', 'Request description'), style: text(14, weight: FontWeight.w700)), const SizedBox(height: 8),
            TextFormField(key: const ValueKey('wallet-notes'), controller: _notes, enabled: !_sending, minLines: 3, maxLines: 5,
              style: text(14), keyboardType: TextInputType.multiline,
              validator: (value) => (value ?? '').trim().isEmpty ? t('أدخل وصف طلب الشحن', 'Enter a request description') : null,
              decoration: _decoration(t('اكتب تفاصيل طلب الشحن', 'Describe your funding request'), Icons.chat_bubble_outline)),
            const SizedBox(height: 18),
          ],
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [const Icon(Icons.info_outline, color: _blue, size: 23), const SizedBox(width: 10),
              Expanded(child: Text(t('إرسال الطلب لا يضيف الرصيد فورًا.', 'Submitting a request does not add funds immediately.'), style: text(12)))])),
          if (_sendError != null) Padding(padding: const EdgeInsets.only(top: 14),
            child: Text(_sendError!, style: text(12, color: const Color(0xFFB42318)))),
          const SizedBox(height: 18),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.chat_bubble_outline, color: _blue, size: 28),
            title: Text(t('لديك استفسار؟', 'Have a question?'), style: text(15, weight: FontWeight.w800)),
            subtitle: Text(t('تواصل معنا', 'Contact us'), style: text(12, color: _blue)), trailing: const Icon(Icons.arrow_forward, color: _blue),
            onTap: _sending ? null : () => Navigator.pushNamed(context, Connect_usRoute)),
        ]))),
      bottomNavigationBar: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE6EDF4)))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _sending ? null : signedIn ? _send
            : () => Navigator.pushNamed(context, loginRoute),
            style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(signedIn ? Icons.send_outlined : Icons.login, size: 22),
            label: Text(_sending ? t('جارٍ الإرسال…', 'Sending…') : signedIn ? t('إرسال طلب الشحن', 'Submit funding request')
              : t('تسجيل الدخول', 'Sign in'), style: text(14, color: Colors.white, weight: FontWeight.w700)))),
          if (signedIn) Padding(padding: const EdgeInsets.only(top: 6),
            child: Text(t('سيتم مراجعة طلبك قبل تحديث الرصيد', 'Your request will be reviewed before the balance is updated'),
              textAlign: TextAlign.center, style: text(10, color: const Color(0xFF64748B), weight: FontWeight.w400))),
        ]))),
    ),
  );
  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: text(12, color: const Color(0xFF8293A4), weight: FontWeight.w400),
    prefixIcon: Icon(icon, color: _blue, size: 24), suffix: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC8D8E6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
    errorStyle: text(10, color: const Color(0xFFB42318), weight: FontWeight.w400),
  );
}
