import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:babco/Shared_Data/CompanyData.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:http/http.dart';


import '../Constans/Api_Services.dart';
import '../Constans/Base_Url.dart';
import '../Localization/Translations.dart';
import '../Models/MaintenanceModel.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<List<MaintenanceModel>?> GetMaintenanceServices(BuildContext context ) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        final dataa = {
          "lang": lang,
        };
        Map<String, String> data = new Map<String, String>.from(dataa);
        print(dataa);
        print(data);
        final response = await Get_Data(maintenance_services, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_GetMaintenanceServices200 ::: ${valueMap['message']} ${valueMap['data']}");
            List<MaintenanceModel> obj= <MaintenanceModel>[];
            if (valueMap['data'] != null) {
              valueMap['data'].forEach((v) {
                obj!.add(new MaintenanceModel.fromJson(v));
              });
            }

            return obj;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_GetMaintenanceServices400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_GetMaintenanceServicesstatusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_GetMaintenanceServicesException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_GetMaintenanceServicesException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_GetMaintenanceServicesException ::: ${e} ");
    return null;
  }
}

Future<bool?> SaveMaintenanceServices(BuildContext context,String mobile ,String station_name,String stationServiceId,
    String address,String lat,String lng,String comment,List<String> ImagesPaths) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);

        var UriData = Uri.parse(CompanyData.companyData!.petrolstation_base_url! + stationmaintenance);

        Map<String, String> headers = {
          "Accept": "application/json",
        };
        MultipartRequest request = new MultipartRequest(
            "POST", UriData);
        request.headers.addAll(headers);
        request.fields['mobile'] = mobile;
        request.fields['lang'] = lang;
        request.fields['station_name'] = station_name;
        request.fields['stationServiceId'] = stationServiceId;
        request.fields['address'] = address;
        request.fields['lat'] = lat;
        request.fields['lng'] = lng;
        request.fields['comment'] = comment;
        if (ImagesPaths != null && ImagesPaths.length > 0) {

            request.files.add(await MultipartFile.fromPath('image', ImagesPaths[ImagesPaths.length-1]));
        }
        var response = await request.send();
        final res = await Response.fromStream(response);
        for(var i in request.fields.keys)
        {
          print(i);
        }
        for(var i in request.fields.values)
        {
          print(i);
        }
        print(request.fields.keys.toString());
        print(request.fields.values.toString());
        print(res.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(res.body);
          if (valueMap['code'] == 200) {
            print( " fn_SaveMaintenanceServices200 ::: ${valueMap['message']} ${valueMap['data']}");
            await AlertView(
                context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);
            return true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_SaveMaintenanceServices400 ::: ${valueMap['message']} ${valueMap['data']}");
            return false;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LSaveMaintenanceServicesstatusCode400 ::: ${response.statusCode} ");
          return false;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_SaveMaintenanceServicesException ::: ${e} ");
        return false;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_SaveMaintenanceServicesException ::: checkInternet ");
      return false;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_SaveMaintenanceServicesException ::: ${e} ");
    return false;
  }
}
