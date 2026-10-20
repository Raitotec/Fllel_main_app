import 'package:flutter/material.dart';
import '../Models/MainModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_View/FalDesign.dart';

class NewOfferPage extends StatelessWidget {
  const NewOfferPage({super.key, required this.data});
  final OffersAndDiscounts data;
  @override
  Widget build(BuildContext context) {
    final description = LanguageData.languageData == 'ar' ? data.descriptionAr : data.descriptionEn;
    return FalPage(title: falText('تفاصيل العرض', 'Offer details'),
      bottom: falButton(falText('تواصل معنا', 'Contact us'), () => Navigator.pushNamed(context, Connect_usRoute)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Container(height: 220, color: const Color(0xFFEEF6FC),
          child: const Stack(alignment: Alignment.center, children: [
            Positioned(right: -30, top: -30, child: Icon(Icons.circle_outlined, size: 150, color: falGold)),
            Icon(Icons.card_giftcard_outlined, size: 100, color: falBlue),
            Positioned(left: 45, bottom: 34, child: Icon(Icons.auto_awesome, size: 30, color: falGold)),
          ]))),
        const SizedBox(height: 18),
        if ((data.discountPercentage ?? '').isNotEmpty) Align(alignment: AlignmentDirectional.centerStart,
          child: Container(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 18), decoration: BoxDecoration(color: falGold, borderRadius: BorderRadius.circular(10)),
            child: Text('${falText('خصم', 'Discount')} ${data.discountPercentage}%', style: falStyle(19, weight: FontWeight.w800)))),
        const SizedBox(height: 16), Text(data.name ?? '', style: falStyle(26, weight: FontWeight.w800)), const SizedBox(height: 20),
        falCard([Text(falText('تفاصيل العرض', 'Offer details'), style: falStyle(18, weight: FontWeight.w800)), const Divider(color: Color(0xFFD2E3F0)),
          Text((description ?? '').isEmpty ? falText('لا توجد تفاصيل إضافية لهذا العرض', 'No additional details are available') : description!, style: falStyle(15, weight: FontWeight.w400))], color: const Color(0xFFF6FAFD)),
        falCard([const Icon(Icons.chat_bubble_outline, color: falBlue, size: 32), const SizedBox(height: 12),
          Text(falText('هل لديك استفسار عن العرض؟', 'Have a question about this offer?'), textAlign: TextAlign.center, style: falStyle(17, weight: FontWeight.w800)),
          const SizedBox(height: 8), Text(falText('تواصل مع فريقنا لمعرفة المزيد', 'Contact our team to learn more'), textAlign: TextAlign.center, style: falStyle(13, weight: FontWeight.w400))], color: const Color(0xFFEEF6FC)),
      ]));
  }
}
