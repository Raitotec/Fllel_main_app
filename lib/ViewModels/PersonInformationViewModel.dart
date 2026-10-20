import 'package:flutter/material.dart';

import '../Api/EditCustomerApi.dart';
import '../Localization/Translations.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_View/AlertView.dart';

class PersonInformationViewModel extends ChangeNotifier {

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool showPasswordFields = false;

  Future<void> GetData(BuildContext context) async {
    if (DelegateData.delegateData != null &&
        DelegateData.delegateData!.id! > 0) {
      showLoading();

      try {
        nameController.text = DelegateData.delegateData!.name ?? "";
        emailController.text = DelegateData.delegateData!.email ?? "";
        mobileController.text = DelegateData.delegateData!.mobile ?? "";
      } finally {
        hideLoading();
      }
    } else {
      await AlertView2(context);
    }
  }

  void togglePasswordFields() {
    showPasswordFields = !showPasswordFields;

    if (!showPasswordFields) {
      currentPasswordController.clear();
      newPasswordController.clear();
    }

    notifyListeners();
  }

  void showLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void hideLoading() {
    _isLoading = false;
    notifyListeners();
  }

  String? passwordValidator(
      BuildContext context,
      String? value,
      )
  {

    if (!showPasswordFields) return null;

    if (currentPasswordController.text.trim().isEmpty &&
        newPasswordController.text.trim().isEmpty) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return Translations.of(context)!.Password_Validation;
    }

    if (value.trim().length < 6) {
      return Translations.of(context)!.password_is_too_short;
    }

    return null;
  }

  Future<void> startFun(BuildContext context) async {

    bool changePassword =
        currentPasswordController.text.trim().isNotEmpty ||
            newPasswordController.text.trim().isNotEmpty;

    if (nameController.text ==
        DelegateData.delegateData!.name &&
        emailController.text ==
            DelegateData.delegateData!.email &&
        mobileController.text ==
            DelegateData.delegateData!.mobile &&
        !changePassword) {

      await AlertView(
        context,
        "error",
        Translations.of(context)!.Please,
        Translations.of(context)!.new_noData,
      );
      showPasswordFields= false;
      notifyListeners();
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    showLoading();

    try {
      if(changePassword==false){
        showPasswordFields= false;
        notifyListeners();
      }
      final res = await EditCustomer(
        context,
        mobileController.text.trim(),
        nameController.text.trim(),
        emailController.text.trim(),
        currentPasswordController.text,
        newPasswordController.text
      );

      if (res != null) {
        DelegateData.delegateData = res;
        await saveDelegateData(res);
        Navigator.pushReplacementNamed(
          context,
          homeRoute,
        );
      }

    } finally {
      hideLoading();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }
}