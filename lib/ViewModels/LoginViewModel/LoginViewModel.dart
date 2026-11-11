import 'package:flutter/material.dart';

import '../../Api/Login/DeleteUserApi.dart';
import '../../Api/Login/LoginApi.dart';
import '../../Routes/route_constants.dart';
import '../../Shared_Data/DelegateData.dart';



class LoginViewModel extends ChangeNotifier {
  bool _disposed = false;
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }
  final formKey = GlobalKey<FormState>();

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSubscription = false;

  void setSubscription(bool value) {
    if (isLoading || _disposed) return;
    isSubscription = value;
    passwordController.clear();
    formKey.currentState?.reset();
    notifyListeners();
  }

  bool isLoading = false;
  Future<void> login(BuildContext context) async {
    if (isLoading || _disposed) return;
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      final res = await Login(
        context,
        identifierController.text.trim(),
        isSubscription ? passwordController.text : null,
      );

      if (!context.mounted || _disposed) return;
      if (res != null) {
        res.type = isSubscription ? 'subscription' : 'default';
        if (!isSubscription) {
          final needsEmailVerification = res.emailVerificationCode == false;
          final email = res.email?.trim() ?? '';
          res.verificationLogin = needsEmailVerification && email.isNotEmpty
              ? email
              : identifierController.text.trim();
          res.isRegistrationVerification = needsEmailVerification;
          Navigator.pushNamed(
            context,
            needsEmailVerification
                ? registrationEmailVerificationRoute
                : verifyCodeRoute,
            arguments: res,
          );
        } else {
         await saveDelegateData(res);
          if (!context.mounted || _disposed) return;
          DelegateData.delegateData=res;
          notifyListeners();
          Navigator.pushNamedAndRemoveUntil(
            context,
            homeRoute,
                (route) => false,
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
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (DelegateData.isSubscription) return;
    if (isLoading || _disposed) return;
    try {
      isLoading = true;
      notifyListeners();

      var x = await deleteAccountFun(context, DelegateData.delegateData!.mobile.toString());
      if (!context.mounted || _disposed) return;
      if (x == true) {
        try {
          await removeDelgateDate();
        } catch (e) { debugPrint('Unable to clear account session'); }
        if (!context.mounted || _disposed) return;
        Navigator.pushNamedAndRemoveUntil(
            context, homeRoute, (Route<dynamic> r) => false);
        return;
      }
    } catch (e) { debugPrint('Account deletion request failed'); }
    isLoading= false;
    notifyListeners();
  }
}
