
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Shared_Data/DelegateData.dart';
import '../../Shared_Data/LanguageData.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<bool?> Contact_us(BuildContext context,String mobile,String comment) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);

        var data = jsonEncode(<String, String>{
          'phone': mobile.trim(),
          "lang": lang,
          "UserId":(DelegateData.delegateData!= null && DelegateData.delegateData!.id!= null&&
              DelegateData.delegateData!.id != -1)?
          DelegateData.delegateData!.id.toString():"",
          // "name":first_name,
          "Message":comment,
          // "contacttype":contacttype
        });
        final response = await Post_Data(contact, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_Contact_us200 ::: ${valueMap['message']} ${valueMap['data']}");
            await AlertView(
                context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);

            return true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_Contact_us400 ::: ${valueMap['message']} ${valueMap['data']}");
            return false;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LContact_usstatusCode400 ::: ${response.statusCode} ");
          return false;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_Contact_usException ::: ${e} ");
        return false;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_Contact_usException ::: checkInternet ");
      return false;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_Contact_usException ::: ${e} ");
    return false;
  }
}
