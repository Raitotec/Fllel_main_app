import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Api/SetvicesApi.dart';
import '../Routes/route_constants.dart';
import '../Shared_View/FalDesign.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key, required this.obj, this.submitRating});
  final String obj;
  final Future<bool?> Function(BuildContext, String, String)? submitRating;
  @override
  State<RatePage> createState() => _RatingState();
}
class _RatingState extends State<RatePage> {
  final _comment = TextEditingController();
  double _rating = 0;
  bool _sending = false;
  @override
  void dispose() { _comment.dispose(); super.dispose(); }
  void _home() => Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false);
  Future<void> _submit() async {
    if (_sending) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('اختر تقييمك أولاً', 'Choose your rating first'))));
      return;
    }
    setState(() => _sending = true);
    try {
      final result = await (widget.submitRating ?? SaveRate)(context, _rating.toString(), _comment.text.trim());
      if (!mounted) return;
      if (result == true) { _home(); }
      else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('لم يُرسل التقييم، أعد المحاولة', 'The rating was not sent. Try again.')))); }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر إرسال التقييم', 'Unable to send the rating'))));
    } finally { if (mounted) setState(() => _sending = false); }
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('طلبك وتقييمك', 'Your order and feedback'), loading: _sending,
    body: ListView(padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
      Center(child: Container(width: 76, height: 76, decoration: const BoxDecoration(color: Color(0xFFEEF6FC), shape: BoxShape.circle), child: const Icon(Icons.check, color: falBlue, size: 44))),
      const SizedBox(height: 16), Text(falText('تم تسجيل طلبك', 'Your order has been registered'), textAlign: TextAlign.center, style: falStyle(25, weight: FontWeight.w800)),
      const SizedBox(height: 8), Text(falText('احتفظ برمز الطلب', 'Keep your order code'), textAlign: TextAlign.center, style: falStyle(13, weight: FontWeight.w400)),
      const SizedBox(height: 18), Center(child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD2E3F0)), borderRadius: BorderRadius.circular(16)),
        child: widget.obj.isEmpty ? Text(falText('رمز الطلب غير متاح', 'Order code unavailable'), style: falStyle(14)) : QrImageView(data: widget.obj, size: 200, padding: const EdgeInsets.all(16), backgroundColor: Colors.white,
          errorStateBuilder: (_, __) => Text(falText('تعذّر عرض رمز الطلب', 'Unable to display order code'), style: falStyle(14))))),
      const SizedBox(height: 22), const Divider(color: Color(0xFFD2E3F0)), const SizedBox(height: 14),
      Text(falText('كيف كانت تجربتك؟', 'How was your experience?'), textAlign: TextAlign.center, style: falStyle(22, weight: FontWeight.w800)), const SizedBox(height: 16),
      Center(child: RatingBar.builder(initialRating: 0, minRating: .5, allowHalfRating: true, itemSize: 38, itemPadding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: falGold), onRatingUpdate: (value) => setState(() => _rating = value))),
      const SizedBox(height: 22), TextField(controller: _comment, minLines: 3, maxLines: 6,
        decoration: InputDecoration(hintText: falText('شاركنا ملاحظاتك (اختياري)', 'Share your feedback (optional)'))),
      const SizedBox(height: 22), falButton(falText('إرسال التقييم', 'Send rating'), _sending ? null : _submit),
      const SizedBox(height: 12), OutlinedButton(onPressed: _sending ? null : _home, child: Text(falText('تخطي والعودة للرئيسية', 'Skip and return home'))),
    ]));
}
