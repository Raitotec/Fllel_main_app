import 'dart:convert';

import 'package:flutter/material.dart';

import '../Constans/Api_Services.dart';
import '../Constans/Base_Url.dart';
import '../Localization/Translations.dart';
import '../Models/DelegateDataModel.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<DelegateDataModel?> EditCustomer(BuildContext context,String mobile ,
    String first_name,String email,String currentPassword, String newPassword) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          'phone': mobile,
          "name":first_name,
          "email":email,
          "lang": lang,
          if (DelegateData.isSubscription) "currentPassword":currentPassword,
          if (DelegateData.isSubscription) "newPassword":newPassword
        });
        final response = await Post_Data(editcustomer+"/"+DelegateData.delegateData!.id!.toString(), data);
        print(response.body);
        //  if (response.statusCode == 200) {
        Map valueMap = jsonDecode(response.body);
        if (valueMap['code'] == 200) {
          print( " fn_Registration200 ::: ${valueMap['message']} ${valueMap['data']}");
          await AlertView(
              context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);
          final previous = DelegateData.delegateData!;
          final x = DelegateDataModel.fromJson({
            ...previous.toJson(),
            'id': valueMap['data']['id'],
            'name': valueMap['data']['name'],
            'mobile': valueMap['data']['phone'],
            'email': valueMap['data']['email'],
          });
          return x;
        }
        else {
          final message = valueMap['message']?.toString().trim() ?? '';
          final error = valueMap['error']?.toString().trim() ?? '';
          final errorMessage = message.isNotEmpty
              ? message
              : error.isNotEmpty
                  ? error
                  : (LanguageData.languageData == 'ar'
                      ? 'حدث خطأ ما'
                      : 'Something went wrong');
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle, errorMessage);
          print( "fn_Registration400 ::: ${valueMap['message']} ${valueMap['data']}");
          return null;
        }
        /* }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LRegistrationstatusCode400 ::: ${response.statusCode} ");
          return null;
        }*/
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_RegistrationException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_RegistrationException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_RegistrationException ::: ${e} ");
    return null;
  }
}
