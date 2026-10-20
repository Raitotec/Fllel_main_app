
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Shared_Data/LanguageData.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future< bool?> deleteAccountFun(BuildContext context, String phone ) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {

        var data = jsonEncode(<String, String>{
          'mobile': phone,
          'lang': LanguageData.languageData
        });
        final response = await Post_Data(Delete_user, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            await AlertView(
                context, "success", Translations.of(context)!.Ok,
                Translations.of(context)!.success_msg);
            return true;
          }
          else if (valueMap['code'] == 300) {
            await AlertView(
                context, "success", Translations.of(context)!.Ok,
                valueMap['message']);
            return true;
          }
          else {
            if (valueMap['error'] != null) {
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,
                  valueMap['error'].toString());
            } else {
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,
                  valueMap['message'].toString());
            }
            print( "fn_loginFun400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(context,"error",Translations.of(context)!.ErrorTitle,"error_statusCode ${response.statusCode} ${response.reasonPhrase} ");
          print( "fn_loginFun_statusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(context,"error",Translations.of(context)!.ErrorTitle,"Exception : ${e.toString()}");
        print( "fn_loginFun_Exception ::: ${e} ");
        return null;
      }

    }
    else {
      await AlertView(context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_loginFun_Exception ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_loginFun_Exception ::: ${e} ");
    return null;
  }
}