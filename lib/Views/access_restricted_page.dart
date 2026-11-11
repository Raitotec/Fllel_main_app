import 'package:flutter/material.dart';
import '../Shared_Data/LanguageData.dart';
import '../Routes/route_constants.dart';

class AccessRestrictedPage extends StatelessWidget {
  const AccessRestrictedPage({super.key, required this.serviceRoute});
  final String serviceRoute;

  (String, String, IconData) get service => switch (serviceRoute) {
    ClientServicePageRoute => ('الخدمات', 'Services', Icons.room_service_rounded),
    StationMaintenancePageRoute => ('صيانة المحطة', 'Station maintenance', Icons.handyman_rounded),
    StationTransportationRoute => ('نقل الوقود', 'Fuel transport', Icons.local_shipping_rounded),
    StationEvaluationRoute => ('تقييم زيارة', 'Rate a visit', Icons.star_rounded),
    StationReviewsRoute => ('تقييم المحطات', 'Station ratings', Icons.local_gas_station_rounded),
    ServiceEvaluationRoute => ('تقييم الخدمات', 'Service ratings', Icons.rate_review_rounded),
    ServicesReviewsRoute => ('مسح QR', 'Scan QR', Icons.qr_code_scanner_rounded),
    _ => ('التقييم', 'Rating', Icons.rate_review_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final ar = LanguageData.languageData == 'ar';
    final (arabicTitle, englishTitle, icon) = service;
    final title = ar ? arabicTitle : englishTitle;
    const blue = Color(0xFF1C6096);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white,
        foregroundColor: const Color(0xFF123D63), centerTitle: true,
        title: Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 21, fontWeight: FontWeight.w800))),
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 210, height: 200, child: Stack(alignment: Alignment.center, children: [
            Container(width: 180, height: 180, decoration: const BoxDecoration(
              color: Color(0xFFEEF6FD), shape: BoxShape.circle)),
            Transform.rotate(angle: -.12, child: Icon(icon, size: 112, color: blue)),
            const Positioned(top: 12, right: 20, child: Icon(Icons.auto_awesome, color: Color(0xFFFFCB22), size: 30)),
            Positioned(bottom: 12, right: 20, child: Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFF5CE), shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5)),
              child: const Icon(Icons.lock_rounded, color: Color(0xFF123D63), size: 32))),
          ])),
          const SizedBox(height: 24),
          Text(ar ? 'الخدمة غير متاحة لحسابك' : 'Service unavailable for your account',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF123D63), height: 1.5)),
          const SizedBox(height: 12),
          Text(ar ? 'ليس لديك صلاحية الوصول إلى هذه الخدمة باستخدام حساب الاشتراكات.' : 'Your subscription account does not have permission to access this service.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () => Navigator.pushNamed(context, Connect_usRoute),
            style: FilledButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            icon: const Icon(Icons.support_agent),
            label: Text(ar ? 'تواصل معنا' : 'Contact us',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, height: 1.5))),
        ]))),
    );
  }
}
