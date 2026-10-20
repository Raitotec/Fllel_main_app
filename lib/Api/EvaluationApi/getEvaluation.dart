import 'dart:convert';

import 'package:babco/Constans/Base_Url.dart';
import 'package:flutter/cupertino.dart';

import '../../Constans/Api_Services.dart';
import '../../Localization/Translations.dart';
import '../../Models/EvaluationModel.dart';
import '../../Shared_Data/LanguageData.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<EvaluationModel?> getEvaluation(BuildContext context, int stationId) async {

  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        Map<String, String> dataa = {
            "lang": lang,
          };
      final response = await Get_Data(
        "${evaluations_station}$stationId",
        dataa,
      );

      print(response.body);
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            final model = EvaluationModel.fromJson(valueMap['data']);
            return model;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['message'].toString());
            print( "fn_Request400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }

      } catch (e) {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
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
