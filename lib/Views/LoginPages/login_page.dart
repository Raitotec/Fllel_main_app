import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Routes/route_constants.dart';
import '../../ViewModels/LoginViewModel/LoginViewModel.dart';
import 'auth_design.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => LoginViewModel(),
    child: Consumer<LoginViewModel>(builder: (context, vm, _) => AuthFrame(
      title: authText('أهلاً بعودتك', 'Welcome back'), subtitle: authText('سجّل الدخول للوصول إلى حسابك وخدماتك', 'Sign in to access your account and services'),
      formKey: vm.formKey, loading: vm.isLoading, children: [
        AuthField(controller: vm.identifierController, label: authText('البريد الإلكتروني أو رقم الجوال', 'Email or mobile number'), icon: Icons.person_outline,
          keyboard: TextInputType.emailAddress, autofill: const [AutofillHints.username],
          validator: (v) => (v ?? '').trim().isEmpty ? authText('أدخل البريد الإلكتروني أو رقم الجوال', 'Enter your email or mobile number') : null),
        AuthField(controller: vm.passwordController, label: authText('كلمة المرور', 'Password'), icon: Icons.lock_outline,
          password: true, autofill: const [AutofillHints.password], validator: (v) => (v ?? '').length < 6 ? authText('كلمة المرور لا تقل عن 6 أحرف', 'Password must contain at least 6 characters') : null),
        const SizedBox(height: 8), authButton(authText('تسجيل الدخول', 'Sign in'), vm.isLoading ? null : () => vm.login(context)),
        const SizedBox(height: 18), TextButton(onPressed: () => Navigator.pushNamed(context, newUserRoute), child: Text(authText('ليس لديك حساب؟ إنشاء حساب', 'New here? Create an account'))),
        const SizedBox(height: 12), const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
        const SizedBox(height: 8), Text(authText('حسابك يجمع خدماتك في مكان واحد', 'Your account brings your services together'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ])));
}
