import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Routes/route_constants.dart';
import '../../ViewModels/LoginViewModel/RegisterViewModel.dart';
import 'auth_design.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => RegisterViewModel(),
    child: Consumer<RegisterViewModel>(builder: (context, vm, _) => AuthFrame(compact: true,
      title: authText('إنشاء حساب', 'Create an account'), subtitle: authText('ابدأ تجربتك مع فلل', 'Start your FAL experience'),
      formKey: vm.formKey, loading: vm.isLoading, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: AuthField(controller: vm.firstNameController, label: authText('الاسم الأول', 'First name'), icon: Icons.person_outline,
            keyboard: TextInputType.name, autofill: const [AutofillHints.givenName], validator: (v) => (v ?? '').trim().length < 2 ? authText('أدخل اسمك', 'Enter your name') : null)),
          const SizedBox(width: 12),
          Expanded(child: AuthField(controller: vm.lastNameController, label: authText('اسم العائلة', 'Last name'), icon: Icons.person_outline,
            keyboard: TextInputType.name, autofill: const [AutofillHints.familyName], validator: (v) => (v ?? '').trim().length < 2 ? authText('أدخل اسم العائلة', 'Enter your last name') : null)),
        ]),
        AuthField(controller: vm.emailController, label: authText('البريد الإلكتروني', 'Email address'), icon: Icons.mail_outline,
          keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.email], validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim()) ? null : authText('أدخل بريدًا صحيحًا', 'Enter a valid email')),
        AuthField(controller: vm.phoneController, label: authText('رقم الجوال', 'Mobile number'), icon: Icons.phone_android_outlined,
          keyboard: TextInputType.phone, autofill: const [AutofillHints.telephoneNumberNational], validator: (v) => RegExp(r'^05[0-9]{8}$').hasMatch((v ?? '').trim()) ? null : authText('رقم الجوال يبدأ بـ05 ويتكون من 10 أرقام', 'Enter a 10-digit number starting with 05')),
        AuthField(controller: vm.passwordController, label: authText('كلمة المرور', 'Password'), icon: Icons.lock_outline,
          password: true, autofill: const [AutofillHints.newPassword], validator: (v) => (v ?? '').length < 6 ? authText('كلمة المرور لا تقل عن 6 أحرف', 'Password must contain at least 6 characters') : null),
        Padding(padding: const EdgeInsets.only(bottom: 20), child: Text(authText('سيتم إرسال رمز التحقق إلى بريدك الإلكتروني', 'A verification code will be sent to your email'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
        authButton(authText('إنشاء الحساب', 'Create account'), vm.isLoading ? null : () => vm.register(context)),
        const SizedBox(height: 14), TextButton(onPressed: () => Navigator.pushReplacementNamed(context, loginRoute), child: Text(authText('لديك حساب؟ تسجيل الدخول', 'Already have an account? Sign in'))),
      ])));
}

