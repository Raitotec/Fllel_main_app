import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Models/CompanyModel.dart';
import '../../Shared_Data/CompanyData.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<CompanyModel?> StartToLogin(BuildContext context,String id) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {

        var base_url_data= company_base_url+id;
        var UriData= Uri.parse(base_url_data);
        print(UriData);
        final response = await http.get(
          UriData,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_Login200 ::: ${valueMap['message']} ${valueMap['data']}");
            var obj= CompanyModel.fromJson(valueMap['data']);
            await saveCompanyData(obj);

            return obj;
          }
          else {
            if (valueMap['error'] != null)
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,
                  valueMap['error'].toString());
            else
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,
                  valueMap['message'].toString());
            print( "fn_Login400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LoginstatusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_LoginException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_LoginException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_LoginException ::: ${e} ");
    return null;
  }
}


