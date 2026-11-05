import 'package:flutter/material.dart';
import '../../Api/Login/RegisterApi.dart';
import '../../Routes/route_constants.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _disposed = false;
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;
  Future<void> register(BuildContext context) async {
    if (isLoading || _disposed) return;
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      var res = await RegistrationFun(context, phoneController.text.trim(),firstNameController.text.trim(),lastNameController.text.trim(),
          emailController.text.trim());
      if (!context.mounted || _disposed) return;
      if (res != null) {
        res.verificationLogin = emailController.text.trim();
        res.isRegistrationVerification = true;
        res.mobile = phoneController.text.trim();
        if (res.requiresVerification == true) {
          Navigator.pushReplacementNamed(
            context,
            verifyCodeRoute,
            arguments: res,
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
