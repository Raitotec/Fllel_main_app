import 'package:flutter/material.dart';
import '../Api/DataApi.dart';
import '../Models/MainModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/BalancePointData.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/DrawerView.dart';
import '../my_app.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
const _yellow = Color(0xFFFFCB22);
class MainScreen extends StatefulWidget {
  final VoidCallback? onStations;
  final VoidCallback? onServices;
  final VoidCallback? onMenu;
  const MainScreen({super.key, this.onStations, this.onServices, this.onMenu});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> with RouteAware {
  bool _loading = true;
  bool _failed = false;
  List<OffersAndDiscounts> _offers = [];
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  @override
  void initState() { super.initState(); _load(); }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }
  @override
  void dispose() { routeObserver.unsubscribe(this); super.dispose(); }
  @override
  void didPopNext() { _load(); }
  Future<void> _load() async {
    try {
      final services = await GetServices(context);
      if (!mounted) return;
      if (services != null) NewServicesData.serviceData = services;
      final data = await AppMainPageFun(context);
      if (!mounted) return;
      setState(() {
        _failed = data == null;
        if (data != null) {
          _offers = data.offersAndDiscounts ?? [];
          BalancePointData.Balance = data.walletBalance ?? '';
          BalancePointData.Point = data.pointsBalance ?? '';
        }
      });
    } catch (_) { if (mounted) setState(() => _failed = true); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  void _route(String route) => Navigator.pushNamed(context, route);
  TextStyle _text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.45);
  BoxDecoration _card({Color color = Colors.white, Color border = const Color(0xFFDFEAF3)}) =>
    BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), border: Border.all(color: border));
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white, drawer: widget.onMenu == null ? DrawerList(context) : null,
    body: RefreshIndicator(color: _blue, onRefresh: _load,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Image.asset('lib/assets/fal_brand.png', width: 88, height: 64, fit: BoxFit.contain),
          Builder(builder: (context) => IconButton(
            tooltip: t('الحساب والقائمة', 'Account and menu'),
            onPressed: widget.onMenu ?? () => Scaffold.of(context).openDrawer(),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFE4EFF9), padding: const EdgeInsets.all(12)),
            icon: const Icon(Icons.person, color: _blue, size: 27))),
        ]),
        Text(t('أهلاً بك', 'Welcome'), style: _text(26, weight: FontWeight.w800)),
        Text(t('كل خدمات محطتك في مكان واحد', 'Your station services, all in one place'),
          style: _text(14, color: const Color(0xFF64748B), weight: FontWeight.w400)),
        const SizedBox(height: 16), _balances(),
        if (_loading) const Padding(padding: EdgeInsets.only(top: 8),
          child: LinearProgressIndicator(minHeight: 2, color: _yellow, backgroundColor: Color(0xFFE4EFF9))),
        if (_failed) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
          Expanded(child: Text(t('تعذر تحديث البيانات', 'Could not refresh data'), style: _text(12))),
          TextButton(onPressed: _load, child: Text(t('حاول مجددًا', 'Retry'))),
        ])),
        const SizedBox(height: 16), _stationCard(),
        const SizedBox(height: 16), _heading(t('خدماتك بسهولة', 'Quick services')),
        const SizedBox(height: 12),
        Row(children: [
          _quick(Icons.local_gas_station_outlined, t('الخدمات', 'Services'),
            widget.onServices ?? () => _route(ClientServicePageRoute)),
          const SizedBox(width: 10),
          _quick(Icons.star_outline_rounded, t('تقييم زيارة', 'Rate a visit'), () => _route(StationEvaluationRoute)),
          const SizedBox(width: 10),
          _quick(Icons.card_giftcard, t('المكافآت', 'Rewards'), () => _route(LoyaltySystemRoute)),
        ]),
        const SizedBox(height: 16), _heading(t('عروض تهمك', 'Offers for you')),
        const SizedBox(height: 12),
        if (_offers.isEmpty) Container(padding: const EdgeInsets.all(20), decoration: _card(),
          child: Text(_loading ? t('جاري تحميل العروض…', 'Loading offers…') : t('لا توجد عروض حاليًا', 'No offers right now'),
            style: _text(14, color: const Color(0xFF64748B)))),
        for (final offer in _offers) _offerCard(offer),
      ])),
  );
  Widget _heading(String label) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: _text(19, weight: FontWeight.w800)), const SizedBox(height: 4),
    Container(width: 24, height: 3, decoration: BoxDecoration(color: _yellow, borderRadius: BorderRadius.circular(8))),
  ]);
  Widget _balances() => Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(20)),
    child: IntrinsicHeight(child: Row(children: [
      _balance(t('رصيد المحفظة', 'Wallet balance'), BalancePointData.Balance,
        Icons.account_balance_wallet_outlined, BalanceRoute, suffix: t('ر.س', 'SAR')),
      const VerticalDivider(color: Color(0xFF5486AE), width: 22, thickness: 1),
      _balance(t('نقاطك', 'Your points'), BalancePointData.Point, Icons.star_rounded, LoyaltySystemRoute),
    ])));
  Widget _balance(String label, String value, IconData icon, String route, {String suffix = ''}) =>
    Expanded(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => _route(route),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: _yellow, size: 22), const SizedBox(width: 6),
          Expanded(child: Text(label, style: _text(13, color: Colors.white)))]),
        const SizedBox(height: 8),
        if (value.isNotEmpty) FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart,
          child: Row(children: [Text(value, textDirection: TextDirection.ltr,
            style: _text(28, color: Colors.white, weight: FontWeight.w800)),
            if (suffix.isNotEmpty) Text(' $suffix', style: _text(12, color: Colors.white))]))
        else Text(_loading ? '—' : t('سجّل الدخول', 'Sign in'), style: _text(16, color: Colors.white)),
      ])));
  Widget _stationCard() => Container(padding: const EdgeInsets.all(14), decoration: _card(),
    child: Row(children: [
      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('أقرب محطة لك', 'Find a station'), style: _text(18, weight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(t('اعثر على محطات فلل القريبة', 'Explore nearby FAL stations'), style: _text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
        const SizedBox(height: 14),
        FilledButton(onPressed: widget.onStations ?? () => _route(station_locationRoute),
          style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text(t('استعرض المحطات', 'View stations'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 18)])),
      ])),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: ClipRRect(borderRadius: BorderRadius.circular(14),
        child: SizedBox(height: 115, child: CustomPaint(painter: _StationMapPainter())))),
    ]));
  Widget _quick(IconData icon, String label, VoidCallback onTap) => Expanded(
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), decoration: _card(),
        child: Column(children: [
          CircleAvatar(radius: 22, backgroundColor: const Color(0xFFFFF5CE), child: Icon(icon, color: _ink, size: 26)),
          const SizedBox(height: 10), Text(label, textAlign: TextAlign.center, style: _text(13, weight: FontWeight.w700)),
        ]))));
  Widget _offerCard(OffersAndDiscounts offer) => Padding(padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => Navigator.pushNamed(context, NewOfferRoute, arguments: offer),
      child: Container(padding: const EdgeInsets.all(16), decoration: _card(color: const Color(0xFFFFFBEC), border: const Color(0xFFFFE69B)),
        child: Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFFFFF1BC), child: Icon(Icons.arrow_forward, color: _blue, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(offer.name ?? '', style: _text(17, weight: FontWeight.w800)), const SizedBox(height: 4),
            Text(t('اكتشف تفاصيل العرض', 'Explore offer details'), style: _text(12, color: const Color(0xFF64748B), weight: FontWeight.w400)),
          ])), const SizedBox(width: 12),
          if ((offer.discountPercentage ?? '').isNotEmpty)
            Text('${offer.discountPercentage}%', textDirection: TextDirection.ltr, style: _text(34, weight: FontWeight.w900)),
        ]))));
}
class _StationMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8F0F8));
    final blocks = Paint()..color = const Color(0xFFD7E5F2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * .45, size.height * .40), blocks);
    canvas.drawRect(Rect.fromLTWH(size.width * .62, size.height * .6, size.width * .4, size.height * .4), blocks);
    final road = Paint()..color = Colors.white..strokeWidth = 10..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, size.height * .18), Offset(size.width + 10, size.height * .88), road);
    canvas.drawLine(Offset(size.width * .2, -10), Offset(size.width * .78, size.height + 10), road);
    canvas.drawLine(Offset(0, size.height * .8), Offset(size.width, size.height * .26), road);
    final center = Offset(size.width * .5, size.height * .49);
    final pin = Path()..moveTo(center.dx, center.dy + 36)
      ..quadraticBezierTo(center.dx - 40, center.dy, center.dx - 22, center.dy - 20)
      ..cubicTo(center.dx - 5, center.dy - 39, center.dx + 29, center.dy - 26, center.dx + 25, center.dy - 6)
      ..quadraticBezierTo(center.dx + 21, center.dy + 11, center.dx, center.dy + 36)..close();
    canvas.drawPath(pin, Paint()..color = _yellow);
    canvas.drawCircle(center.translate(0, -8), 14, Paint()..color = Colors.white);
    canvas.drawCircle(center.translate(0, -8), 8, Paint()..color = _blue);
  }
  @override
  bool shouldRepaint(covariant _StationMapPainter oldDelegate) => false;
}

