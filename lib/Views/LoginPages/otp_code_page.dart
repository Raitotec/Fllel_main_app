import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Models/DelegateDataModel.dart';
import '../../ViewModels/LoginViewModel/OtpViewModel.dart';
import 'auth_design.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.data});
  final DelegateDataModel data;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => OtpViewModel(data: data)..startTimer(),
    child: Consumer<OtpViewModel>(builder: (context, vm, _) => AuthFrame(compact: true,
      title: authText('تحقق من بريدك', 'Verify your email'), subtitle: authText('أدخل رمز التحقق المرسل إلى بريدك الإلكتروني', 'Enter the verification code sent to your email'),
      formKey: vm.formKey, loading: vm.isLoading, children: [
        const Icon(Icons.mark_email_read_outlined, color: authBlue, size: 62), const SizedBox(height: 14),
        Text(data.email ?? '', textDirection: TextDirection.ltr, textAlign: TextAlign.center, style: const TextStyle(color: authBlue, fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        TextFormField(controller: vm.otpController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, textAlign: TextAlign.center,
          autofillHints: const [AutofillHints.oneTimeCode], inputFormatters: [TextInputFormatter.withFunction((oldValue, newValue) {
            const source = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
            var normalized = newValue.text;
            for (var i = 0; i < source.length; i++) { normalized = normalized.replaceAll(source[i], '${i % 10}'); }
            return newValue.copyWith(text: normalized);
          }), FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 25, letterSpacing: 10, color: authInk),
          decoration: InputDecoration(labelText: authText('رمز التحقق', 'Verification code'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD2DFEA)))),
          validator: (v) => (v ?? '').isEmpty ? authText('أدخل رمز التحقق', 'Enter the verification code') : null),
        const SizedBox(height: 24), authButton(authText('تأكيد الرمز', 'Confirm code'), vm.isLoading ? null : () => vm.verifyCode(context)),
        const SizedBox(height: 22),
        if (!vm.isExpired) Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEEF6FC), borderRadius: BorderRadius.circular(14)),
          child: Text('${authText('يمكنك إعادة الإرسال بعد', 'Resend available in')} ${vm.formattedTime}', textAlign: TextAlign.center, style: const TextStyle(color: authBlue))),
        TextButton(onPressed: vm.isExpired && !vm.isLoading ? () => vm.resendCode(context) : null, child: Text(authText('إعادة إرسال الرمز', 'Resend code'))),
        const SizedBox(height: 12), Text(authText('لم يصلك الرمز؟ تحقق من البريد غير المرغوب فيه', 'No code received? Check your spam folder'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ])));
}
