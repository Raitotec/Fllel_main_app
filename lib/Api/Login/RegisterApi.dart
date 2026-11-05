import 'dart:convert';

import 'package:babco/Models/DelegateDataModel.dart';
import 'package:flutter/material.dart';

import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<DelegateDataModel?> RegistrationFun(BuildContext context,String mobile ,String first_name,
    String last_name,String email) async
{
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var data = jsonEncode(<String, String>{
          'mobile': mobile,
          "first_name":first_name,
          "last_name":last_name,
          "email":email,
        });
        final response = await Post_Data(registration, data);
        print(response.body);
        Map valueMap = jsonDecode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300 && (valueMap['success'] == true || valueMap['code'] == 200 || valueMap['code'] == 201)) {
          print( " fn_Registration200 ::: ${valueMap['message']} ${valueMap['data']}");
          DelegateDataModel obj= DelegateDataModel.fromJson(valueMap['data'] is Map ? Map<String, dynamic>.from(valueMap['data']) : <String, dynamic>{});
          await AlertView(context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);
          return obj;
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,valueMap['message'].toString());
          print( "fn_Registration400 ::: ${valueMap['message']} ${valueMap['data']}");
          return null;
        }
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
