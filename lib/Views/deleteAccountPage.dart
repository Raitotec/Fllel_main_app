import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Routes/route_constants.dart';
import '../Shared_View/FalDesign.dart';
import '../ViewModels/LoginViewModel/LoginViewModel.dart';

// Kept for compatibility with existing route imports.
// ignore: camel_case_types
class deleteAccountPage extends StatelessWidget {
  const deleteAccountPage({super.key});
  Future<void> _confirm(BuildContext context, LoginViewModel vm) async {
    final accepted = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: Text(falText('تأكيد حذف الحساب', 'Confirm account deletion'), style: falStyle(19, weight: FontWeight.w800)),
      content: Text(falText('هل تريد حذف حسابك نهائيًا؟ لا يمكنك التراجع بعد الحذف.', 'Delete your account permanently? This action cannot be undone.'), style: falStyle(14)),
      actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(falText('إلغاء', 'Cancel'))),
        TextButton(onPressed: () => Navigator.pop(dialog, true), child: Text(falText('حذف الحساب', 'Delete account'), style: const TextStyle(color: Color(0xFFB42318))))]));
    if (!context.mounted || accepted != true) return;
    await vm.deleteAccount(context);
  }
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => LoginViewModel(),
    child: Consumer<LoginViewModel>(builder: (context, vm, _) => FalPage(title: falText('حذف الحساب', 'Delete account'), loading: vm.isLoading,
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 26), Center(child: Container(width: 140, height: 140, decoration: const BoxDecoration(color: Color(0xFFFDECEC), shape: BoxShape.circle),
          child: const Icon(Icons.delete_outline, size: 70, color: Color(0xFFB42318)))),
        const SizedBox(height: 30), Text(falText('هل تريد حذف حسابك؟', 'Do you want to delete your account?'), textAlign: TextAlign.center, style: falStyle(24, weight: FontWeight.w800)),
        const SizedBox(height: 14), Text(falText('سيتم حذف حسابك نهائيًا، ولن تتمكن من استعادته.', 'Your account will be permanently deleted and cannot be restored.'), textAlign: TextAlign.center, style: falStyle(14, weight: FontWeight.w400)),
        const SizedBox(height: 30), falCard([const Icon(Icons.support_agent, color: falBlue, size: 36),
          Text(falText('تحتاج مساعدة؟', 'Need help?'), textAlign: TextAlign.center, style: falStyle(18, weight: FontWeight.w800)),
          TextButton(onPressed: () => Navigator.pushNamed(context, Connect_usRoute), child: Text(falText('تواصل معنا', 'Contact us')))], color: const Color(0xFFEEF6FC)),
        const SizedBox(height: 14), OutlinedButton(onPressed: vm.isLoading ? null : () => _confirm(context, vm),
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB42318), minimumSize: const Size.fromHeight(52), side: const BorderSide(color: Color(0xFFB42318)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text(falText('متابعة حذف الحساب', 'Continue account deletion'), style: falStyle(14, color: const Color(0xFFB42318)))),
        const SizedBox(height: 14), falButton(falText('الاحتفاظ بحسابي', 'Keep my account'), vm.isLoading ? null : () => Navigator.pop(context)),
      ]))));
}
