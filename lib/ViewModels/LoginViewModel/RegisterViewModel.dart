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
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscureText = true;

  void togglePassword() {
    obscureText = !obscureText;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    if (isLoading || _disposed) return;
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      var res = await RegistrationFun(context, phoneController.text,firstNameController.text,lastNameController.text,
          emailController.text,passwordController.text);
      if (!context.mounted || _disposed) return;
      if (res != null) {
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
    passwordController.dispose();
    super.dispose();
  }
}
