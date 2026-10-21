import 'package:flutter/material.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';
import '../Views/home_page.dart';
import 'FalDesign.dart';

// Kept for existing callers; the drawer now shares the app's navigation and identity.
// ignore: non_constant_identifier_names
Widget DrawerList(BuildContext context, {int id = 0}) => _FalDrawer(id: id);
class _FalDrawer extends StatelessWidget {
  const _FalDrawer({required this.id});
  final int id;
  void _open(BuildContext context, String route, {Object? arguments}) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route, arguments: arguments);
  }
  void _home(BuildContext context, int index) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(initialIndex: index)), (_) => false);
  }
  Widget _row(BuildContext context, IconData icon, String label, VoidCallback action) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
    leading: Icon(icon, color: falBlue, size: 25), title: Text(label, style: falStyle(14, weight: FontWeight.w700)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF7A8CA0)), onTap: action);
  Widget _section(String label) => Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 8), child: Text(label, style: falStyle(12, color: falBlue, weight: FontWeight.w800)));
  @override
  Widget build(BuildContext context) {
    final signed = (DelegateData.delegateData?.id ?? -1) > 0;
    return Drawer(width: MediaQuery.sizeOf(context).width * .86, backgroundColor: Colors.white, surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(18))),
      child: SafeArea(child: Column(children: [
        Container(width: double.infinity, color: const Color(0xFFEEF6FC), padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [Image.asset('lib/assets/fal_brand.png', width: 85, height: 65), const Spacer(),
            IconButton(tooltip: falText('إغلاق القائمة', 'Close menu'), onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: falInk))]), const SizedBox(height: 12),
            Row(children: [const CircleAvatar(backgroundColor: Color(0xFFDCECF7), child: Icon(Icons.person_outline, color: falBlue)), const SizedBox(width: 12),
              Expanded(child: Text(signed ? DelegateData.delegateData?.name ?? falText('حسابي', 'Account') : falText('أهلاً بك', 'Welcome'), style: falStyle(17, weight: FontWeight.w800)))]),
            Align(alignment: AlignmentDirectional.centerStart, child: TextButton(onPressed: () => signed ? _home(context, 4) : _open(context, loginRoute),
              child: Text(falText(signed ? 'إدارة الحساب' : 'تسجيل الدخول', signed ? 'Manage account' : 'Sign in'), style: falStyle(12, color: falBlue)))),
          ])),
        Expanded(child: ListView(padding: const EdgeInsets.only(top: 10, bottom: 20), children: [
          _row(context, Icons.home_outlined, falText('الرئيسية', 'Home'), () => _home(context, 0)),
          _row(context, Icons.location_on_outlined, falText('المحطات', 'Stations'), () => _home(context, 1)),
          _row(context, Icons.grid_view_outlined, falText('استعرض الخدمات', 'Browse services'), () => _home(context, 2)),
          _row(context, Icons.card_giftcard_outlined, falText('المكافآت', 'Rewards'), () => _home(context, 3)),
          _section(falText('طلب الخدمات', 'Service requests')),
          _row(context, Icons.qr_code_2, falText('تعبئة الوقود', 'Fuel card'), () => _open(context, fuelCardRoute)),
          _row(context, Icons.history, falText('حركات الوقود', 'Fuel history'), () => _open(context, fuelHistoryRoute)),
          _row(context, Icons.add_shopping_cart, falText('طلب خدمة', 'Request a service'), () => _open(context, ClientServicePageRoute)),
          _row(context, Icons.handyman_outlined, falText('صيانة المحطة', 'Station maintenance'), () => _open(context, StationMaintenancePageRoute)),
          _row(context, Icons.local_shipping_outlined, falText('نقل الوقود', 'Fuel transport'), () => _open(context, StationTransportationRoute)),
          _section(falText('التقييمات', 'Evaluations')),
          _row(context, Icons.star_outline, falText('تقييم المحطات', 'Rate stations'), () => _open(context, StationEvaluationRoute)),
          _row(context, Icons.rate_review_outlined, falText('تقييم الخدمات', 'Rate services'), () => _open(context, ServiceEvaluationRoute)),
          _row(context, Icons.qr_code_scanner, falText('مسح QR', 'Scan QR'), () => _open(context, ServicesReviewsRoute)),
          _section(falText('حسابك', 'Your account')),
          _row(context, Icons.account_balance_wallet_outlined, falText('المحفظة', 'Wallet'), () => _open(context, BalanceRoute)),
          _row(context, Icons.receipt_long_outlined, falText('طلباتي', 'My orders'), () => _open(context, RequestsRoute)),
          _row(context, Icons.settings_outlined, falText('الحساب والإعدادات', 'Account and settings'), () => _home(context, 4)),
          _section(falText('الدعم', 'Help')),
          _row(context, Icons.chat_bubble_outline, falText('تواصل معنا', 'Contact us'), () => _open(context, Connect_usRoute)),
          _row(context, Icons.info_outline, falText('من نحن', 'About us'), () => _open(context, AboutUsRoute)),
        ])),
      ])));
  }
}
