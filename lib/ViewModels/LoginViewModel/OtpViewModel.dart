import 'dart:async';
import 'package:babco/Api/Login/VerifyResendCode.dart';
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:flutter/material.dart';

import '../../Api/Login/Verifycode.dart';
import '../../Routes/route_constants.dart';

class OtpViewModel extends ChangeNotifier {
  bool _disposed = false;
  DateTime? _resendAt;
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }
  final DelegateDataModel data;

  OtpViewModel({
    required this.data,
  });

  final formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  bool isLoading = false;

  static const int otpDuration = 1 * 60; // 15 minutes

  int remainingSeconds = otpDuration;

  Timer? _timer;

  bool get isExpired => remainingSeconds <= 0;

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  void startTimer() {
    _timer?.cancel();

    remainingSeconds = otpDuration;
    _resendAt = DateTime.now().add(const Duration(seconds: otpDuration));

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        remainingSeconds = (_resendAt!.difference(DateTime.now()).inMilliseconds / 1000).ceil().clamp(0, otpDuration);
        if (remainingSeconds <= 0) {
          timer.cancel();
        }

        notifyListeners();
      },
    );
  }

  Future<void> verifyCode(BuildContext context) async {
    if (isLoading || _disposed) return;
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
     var res= await Verifycode(context, data.mobile??"", otpController.text);
        if (!context.mounted || _disposed) return;
        if (res != null) {
          DelegateData.delegateData=res;
          await saveDelegateData(res);
          if (!context.mounted || _disposed) return;
          notifyListeners();
          Navigator.pushNamedAndRemoveUntil(context, homeRoute,(Route<dynamic> r)=>false);
        }
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> resendCode(BuildContext context) async {
    if (isLoading || !isExpired || _disposed) return;

    isLoading = true;
    notifyListeners();

    try {
      var res = await VerifyResendCode(context, data.mobile ?? "");
      if (!context.mounted || _disposed) return;
      if (res != null) {
        startTimer();
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
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
