import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';
import '../ViewModels/PersonInformationViewModel.dart';

const _blue = Color(0xFF1C6096);
const _ink = Color(0xFF123D63);
class PersonInformationPage extends StatelessWidget {
  const PersonInformationPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => PersonInformationViewModel(), child: const _ProfileBody());
}
class _ProfileBody extends StatefulWidget {
  const _ProfileBody();
  @override
  State<_ProfileBody> createState() => _ProfileState();
}
class _ProfileState extends State<_ProfileBody> {
  bool _hideCurrent = true, _hideNew = true;
  bool get signedIn => (DelegateData.delegateData?.id ?? -1) > 0;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  TextStyle text(double size, {Color color = _ink, FontWeight weight = FontWeight.w600}) =>
    TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.5);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && signedIn) context.read<PersonInformationViewModel>().GetData(context);
    });
  }
  @override
  Widget build(BuildContext context) => Consumer<PersonInformationViewModel>(builder: (context, vm, _) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white,
          elevation: 0, foregroundColor: _ink, centerTitle: true, toolbarHeight: 64,
          leading: IconButton(tooltip: t('رجوع', 'Back'), onPressed: vm.isLoading ? null : () => Navigator.pop(context), icon: const BackButtonIcon()),
          title: Text(t('معلوماتي', 'My information'), style: text(21, weight: FontWeight.w800)),
          actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 64, height: 48))]),
        body: !signedIn ? Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.lock_outline, color: _blue, size: 48),
            const SizedBox(height: 16), Text(t('سجّل الدخول لإدارة بياناتك', 'Sign in to manage your information'), textAlign: TextAlign.center, style: text(17)),
            const SizedBox(height: 20), FilledButton(onPressed: () => Navigator.pushNamed(context, loginRoute),
              style: FilledButton.styleFrom(backgroundColor: _blue),
              child: Text(t('تسجيل الدخول', 'Sign in'), style: text(14, color: Colors.white))),
          ])))
          : AbsorbPointer(absorbing: vm.isLoading, child: Form(key: vm.formKey,
            child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
              Center(child: Container(width: 84, height: 84,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFCB22), width: 3)),
                child: const Icon(Icons.person_outline, color: _ink, size: 50))),
              const SizedBox(height: 12),
              Text((DelegateData.delegateData?.name ?? '').trim(), textAlign: TextAlign.center, style: text(22, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(t('إدارة بيانات حسابك', 'Manage your account information'), textAlign: TextAlign.center,
                style: text(13, color: const Color(0xFF64748B), weight: FontWeight.w400)),
              const SizedBox(height: 24),
              _field(t('الاسم', 'Name'), vm.nameController, Icons.person_outline,
                keyboard: TextInputType.name, autofill: const [AutofillHints.name], validator: (value) =>
                  (value ?? '').trim().length < 2 ? t('أدخل اسمًا لا يقل عن حرفين', 'Enter a name of at least 2 characters') : null),
              const SizedBox(height: 18),
              _field(t('البريد الإلكتروني', 'Email'), vm.emailController, Icons.mail_outline,
                keyboard: TextInputType.emailAddress, ltr: true, autofill: const [AutofillHints.email],
                validator: (value) => !RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch((value ?? '').trim())
                  ? t('أدخل بريدًا إلكترونيًا صحيحًا', 'Enter a valid email address') : null),
              const SizedBox(height: 18),
              _field(t('رقم الجوال', 'Mobile number'), vm.mobileController, Icons.phone_outlined,
                keyboard: TextInputType.phone, ltr: true, autofill: const [AutofillHints.telephoneNumberNational],
                validator: (value) => !RegExp(r'^05[0-9]{8}$').hasMatch((value ?? '').trim())
                  ? t('أدخل رقم جوال صحيحًا يبدأ بـ05', 'Enter a valid 10-digit mobile number starting with 05') : null),
              const SizedBox(height: 26),
              Text(t('أمان الحساب', 'Account security'), style: text(19, weight: FontWeight.w800)),
              const SizedBox(height: 5),
              Align(alignment: AlignmentDirectional.centerStart, child: Container(width: 34, height: 3, color: const Color(0xFFFFCB22))),
              const SizedBox(height: 14),
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD2DFEA)), borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  Row(children: [const Icon(Icons.lock_outline, color: _blue, size: 26), const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t('كلمة المرور', 'Password'), style: text(15, weight: FontWeight.w800)),
                      Text(t('غيّر كلمة المرور لحماية حسابك', 'Change your password to protect your account'),
                        style: text(10, color: const Color(0xFF64748B), weight: FontWeight.w400)),
                    ])),
                    TextButton(onPressed: () { vm.togglePasswordFields(); setState(() { _hideCurrent = true; _hideNew = true; }); },
                      child: Text(vm.showPasswordFields ? t('إلغاء', 'Cancel') : t('تعديل', 'Edit'), style: text(13, color: _blue))),
                  ]),
                  if (vm.showPasswordFields) ...[
                    const SizedBox(height: 18),
                    _field(t('كلمة المرور الحالية', 'Current password'), vm.currentPasswordController, Icons.lock_outline,
                      password: true, obscured: _hideCurrent, autofill: const [AutofillHints.password],
                      toggle: () => setState(() => _hideCurrent = !_hideCurrent), validator: (value) => vm.passwordValidator(context, value)),
                    const SizedBox(height: 16),
                    _field(t('كلمة المرور الجديدة', 'New password'), vm.newPasswordController, Icons.lock_outline,
                      password: true, obscured: _hideNew, autofill: const [AutofillHints.newPassword],
                      toggle: () => setState(() => _hideNew = !_hideNew), validator: (value) => vm.passwordValidator(context, value)),
                  ],
                ])),
              const SizedBox(height: 18),
              Container(padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFEEF6FD), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [const Icon(Icons.info_outline, color: _blue, size: 23), const SizedBox(width: 10),
                  Expanded(child: Text(t('راجع بياناتك قبل حفظ التغييرات', 'Review your information before saving'), style: text(11, color: _blue)))])),
            ]))),
        bottomNavigationBar: !signedIn ? null : SafeArea(top: false, child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 4), decoration: const BoxDecoration(color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE6EDF4)))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: vm.isLoading ? null : () {
              FocusScope.of(context).unfocus();
              if (vm.formKey.currentState?.validate() == true) vm.startFun(context);
            }, style: FilledButton.styleFrom(backgroundColor: _blue, padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: vm.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check, size: 22),
              label: Text(vm.isLoading ? t('جارٍ الحفظ…', 'Saving…') : t('حفظ التغييرات', 'Save changes'),
                style: text(14, color: Colors.white, weight: FontWeight.w700)))),
            TextButton(onPressed: vm.isLoading ? null : () => Navigator.pop(context),
              child: Text(t('إلغاء', 'Cancel'), style: text(12, color: _blue))),
          ]))),
      ),
    );
  });
  Widget _field(String label, TextEditingController controller, IconData icon,
    {TextInputType keyboard = TextInputType.text, bool ltr = false, bool password = false,
      bool obscured = true, VoidCallback? toggle, List<String>? autofill, String? Function(String?)? validator}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: text(14, weight: FontWeight.w700)), const SizedBox(height: 8),
      TextFormField(controller: controller, keyboardType: keyboard, textDirection: ltr ? TextDirection.ltr : null,
        style: text(15), obscureText: password && obscured, enableSuggestions: !password, autocorrect: !password,
        autofillHints: autofill, validator: validator, autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: _ink, size: 23),
          suffixIcon: password ? IconButton(tooltip: obscured ? t('إظهار كلمة المرور', 'Show password') : t('إخفاء كلمة المرور', 'Hide password'),
            onPressed: toggle, icon: Icon(obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _blue, size: 22)) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC8D8E6))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 1.5)),
          errorStyle: text(10, color: const Color(0xFFB42318), weight: FontWeight.w400)),
      ),
    ]);
}
