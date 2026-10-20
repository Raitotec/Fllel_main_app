import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:babco/Shared_Data/DelegateData.dart';

import '../Constans/Api_Services.dart';
import '../Constans/Base_Url.dart';
import '../Localization/Translations.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<bool?> CustomersClaim(BuildContext context,String mobile ,String first_name,String comment) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          'mobile': mobile,
          "lang": lang,
          "customer_id":DelegateData.delegateData!.id.toString(),
          "name":first_name,
          "comment":comment
        });
        final response = await Post_Data(claim, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_Claim200 ::: ${valueMap['message']} ${valueMap['data']}");
            await AlertView(
                context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);
            return true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_Claim400 ::: ${valueMap['message']} ${valueMap['data']}");
            return false;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LClaimstatusCode400 ::: ${response.statusCode} ");
          return false;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_ClaimException ::: ${e} ");
        return false;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_ClaimException ::: checkInternet ");
      return false;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_ClaimException ::: ${e} ");
    return false;
  }
}
