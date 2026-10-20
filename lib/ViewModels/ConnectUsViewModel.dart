import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Api/Contact_us/GetContactsDataApi.dart';
import '../Api/Contact_us/SendCommentApi.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/DelegateData.dart';

class ConnectUsViewModel extends ChangeNotifier {

  final formKey = GlobalKey<FormState>();

  final commentController = TextEditingController();
  final mobileController = TextEditingController();

  bool isLoading = false;
  bool _disposed = false;

  String whatsappNumber = "";
  String websiteUrl = "";

  BuildContext? context;

  void init(BuildContext ctx) {
    context ??= ctx;
    getData();
  }

  void _setLoading(bool value) {
    if (_disposed) return;
    isLoading = value;
    notifyListeners();
  }

  Future<void> getData() async {
    if (DelegateData.delegateData?.mobile != null) {
      mobileController.text = DelegateData.delegateData!.mobile!;
    }

    _setLoading(true);

    var data = await GetContactUs(context!);
    if (_disposed) return;

    if (data != null) {
      whatsappNumber = data.whatsappNumber ?? "";
      websiteUrl = data.siteLink ?? "";
    }

    _setLoading(false);
  }

  Future<void> sendMessage() async {
    if (isLoading || _disposed) return;

    if (!formKey.currentState!.validate()) return;

    _setLoading(true);

    bool? res = await Contact_us(
      context!,
      mobileController.text,
      commentController.text,
    );

    _setLoading(false);
    if (_disposed) return;

    if (res== true) {
      Navigator.pushNamedAndRemoveUntil(context!, homeRoute,(Route<dynamic> r)=>false);
    }
  }

  Future<void> openWhatsApp() async {
    var number = whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (number.startsWith('00')) number = number.substring(2);
    if (number.startsWith('05') && number.length == 10) number = '966${number.substring(1)}';
    if (number.isEmpty) return;
    final url = "https://wa.me/$number";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> openWebsite() async {

    String url = websiteUrl;

    if (!url.startsWith("http")) {
      url = "https://$url";
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    commentController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}
