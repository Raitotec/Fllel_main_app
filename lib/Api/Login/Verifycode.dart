import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Models/DelegateDataModel.dart';
import '../../Shared_Data/DelegateData.dart';
import '../../Shared_Data/LanguageData.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<DelegateDataModel?> Verifycode(BuildContext context,String mobile ,String code) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          'mobile': mobile,
          "code":code,
          "lang": lang,
        });
        final response = await Post_Data(verifycode, data);
        print(response.body);
        //   if (response.statusCode == 200) {
        Map valueMap = jsonDecode(response.body);
        if (valueMap['code'] == 200) {
          print( " fn_Verifycode200 ::: ${valueMap['message']} ${valueMap['data']}");
          var obj= DelegateDataModel.fromJson(valueMap['data']);
          await saveDelegateData(obj);

          return obj;
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,valueMap['message'].toString());
          print( "fn_Verifycode400 ::: ${valueMap['message']} ${valueMap['data']}");
          return null;
        }
        /*  }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_VerifycodestatusCode400 ::: ${response.statusCode} ");
          return null;
        }*/
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_VerifycodeException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_VerifycodeException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_VerifycodeException ::: ${e} ");
    return null;
  }
}
