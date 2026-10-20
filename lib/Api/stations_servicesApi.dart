import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:babco/Constans/Base_Url.dart';

import '../Constans/Api_Services.dart';
import '../Localization/Translations.dart';
import '../Models/PinDataModel.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<List<PinDataModel>?> Allstations(BuildContext context ) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          "lang": lang,
        });
        final response = await Post_Data(allstations, data);
        print(response.body);
        if (response.statusCode == 200) {
          print("((((");
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_Allstations200 ::: ${valueMap['message']} ${valueMap['data']}");
           List<PinDataModel> obj= <PinDataModel>[];
            if (valueMap['data'] != null) {
              valueMap['data'].forEach((v) {
                obj!.add(new PinDataModel.fromJson(v));
              });
            }
            
            return obj;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_Allstations400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_AllstationsstatusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_AllstationsException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_AllstationsException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_AllstationsException ::: ${e} ");
    return null;
  }
}
