import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';
import '../Routes/route_constants.dart';
import 'FalDesign.dart';

// Compatibility entry points used by the existing API layer.
// ignore: non_constant_identifier_names
Future<void> AlertView(BuildContext context, String image, String title, String description, {int id = 0}) async {
  if (!context.mounted) return;
  final success = image == 'success';
  final message = description.startsWith('Exception') || description.startsWith('error_statusCode')
    ? falText('تعذّر إكمال العملية. أعد المحاولة.', 'Unable to complete the operation. Please try again.') : description;
  await showDialog<void>(context: context, builder: (dialog) => AlertDialog(backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    icon: Icon(success ? Icons.check_circle_outline : image == 'warning' ? Icons.info_outline : Icons.error_outline,
      color: success ? falBlue : image == 'warning' ? falInk : const Color(0xFFB42318), size: 42),
    title: Text(title, textAlign: TextAlign.center, style: falStyle(20, weight: FontWeight.w800)),
    content: Text(message, textAlign: TextAlign.center, style: falStyle(14, weight: FontWeight.w400)),
    actions: [falButton(id == 0 ? falText('حسنًا', 'OK') : falText('تحديث التطبيق', 'Update app'), () async {
      Navigator.pop(dialog);
      if (id != 0) { try { await StoreRedirect.redirect(androidAppId: 'com.raitotec.fall', iOSAppId: '585027354'); } catch (_) { } }
    })]));
}
// ignore: non_constant_identifier_names
Future<void> AlertView2(BuildContext context) async {
  if (!context.mounted) return;
  final login = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), icon: const Icon(Icons.lock_outline, color: falBlue, size: 42),
    title: Text(falText('تسجيل الدخول', 'Sign in'), style: falStyle(20, weight: FontWeight.w800)),
    content: Text(falText('سجّل الدخول للمتابعة باستخدام حسابك', 'Sign in to continue with your account'), style: falStyle(14)),
    actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(falText('إلغاء', 'Cancel'))),
      TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(falText('تسجيل الدخول', 'Sign in')))]));
  if (context.mounted && login == true) await Navigator.pushNamed(context, loginRoute);
}
