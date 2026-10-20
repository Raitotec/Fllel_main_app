import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:babco/Shared_Data/DelegateData.dart';

import '../Constans/Api_Services.dart';
import '../Constans/Base_Url.dart';
import '../Localization/Translations.dart';
import '../Models/AboutModel.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<bool?> WalletRequestFun(BuildContext context,String description, String amount ) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          "lang": lang,
            "customer_id" :DelegateData.delegateData!.id.toString(),
            "amount" : amount,
            "description" : description
        });
        final response = await Post_Data(WalletRequest, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_WalletRequest200 ::: ${valueMap['message']} ${valueMap['data']}");
             await AlertView(context, "success", Translations.of(context)!.Ok,valueMap['data']['message']);
            return  true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_WalletRequest400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LWalletRequeststatusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_WalletRequestException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_WalletRequestException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_WalletRequestException ::: ${e} ");
    return null;
  }
}
Future<bool?> ConvertPointsFun(BuildContext context ) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          "lang": lang,
            "customer_id" :DelegateData.delegateData!.id.toString(),
        });
        final response = await Post_Data(ConvertPoints, data);
        print(response.body);
      //  if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_ConvertPoints200 ::: ${valueMap['message']} ${valueMap['data']}");
             await AlertView(context, "success", Translations.of(context)!.Ok,valueMap['data']['message']);
            return  true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['message'].toString());
            print( "fn_ConvertPoints400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
       /* }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_ConvertPointsstatusCode400 ::: ${response.statusCode} ");
          return null;
        }*/
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_ConvertPointsException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_ConvertPointsException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_ConvertPointsException ::: ${e} ");
    return null;
  }
}
