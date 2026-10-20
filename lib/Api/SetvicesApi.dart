import 'package:babco/Models/OrderModel.dart';
import 'package:babco/Models/ServicesModel.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:babco/Constans/Base_Url.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../Constans/Api_Services.dart';
import '../Localization/Translations.dart';
import '../Models/PinDataModel.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/LocationData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<List<ServicesModel>?> GetAllServices(BuildContext context ,String station_id) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        Map<String, String> dataa;
        if(station_id == null || station_id.isEmpty|| station_id.length<0 ) {
           dataa = {
            "lang": lang,
          };
        }
        else {
          dataa = {
            "lang": lang,
            "station_id": station_id
          };
        }

        Map<String, String> data = new Map<String, String>.from(dataa);
        print(dataa);
        print(data);
        final response = await Get_Data(AllServices, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_GetAllServicess200 ::: ${valueMap['message']} ${valueMap['data']}");
            List<ServicesModel> obj= <ServicesModel>[];
            if (valueMap['data'] != null) {
              valueMap['data'].forEach((v) {
                obj!.add(new ServicesModel.fromJson(v));
              });
            }

            return obj;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_GetAllServicess400 ::: ${valueMap['message']} ${valueMap['data']}");
            return null;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_GetAllServicessstatusCode400 ::: ${response.statusCode} ");
          return null;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_GetAllServicessException ::: ${e} ");
        return null;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_GetAllServicessException ::: checkInternet ");
      return null;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_GetAllServicessException ::: ${e} ");
    return null;
  }
}

Future<String> AddOrder(BuildContext context,OrderModel order)
async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        Position? position=await getLocationData(context);
        if(position != null)
        {
          order.lat=position.latitude.toString();
          order.lng=position.longitude.toString();
          order.lang= lang;

          try {
            if (order.address != null && order.address!.length > 0) {
            }
            else {
              List<Placemark> addresses = await placemarkFromCoordinates(
                  position.latitude, position.longitude);
              var first = addresses.first;
              order.address = first.street! + "," + first.locality! + "," +
                  first.administrativeArea! + "," + first.country!;
            }
          }
          catch(e) {}
          var data=jsonEncode(order.toJson());
          final response = await Post_Data(savecart, data);
          print(data);
          if (response.statusCode == 200) {
            Map valueMap = jsonDecode(response.body);
            if (valueMap['code'] == 200) {
              print(" fn_AddOrderFun200 ::: ${valueMap['message']} ${valueMap['data']}");
              print({valueMap['data']['url']});
              await AlertView(context, "success", Translations.of(context)!.Ok, Translations.of(context)!.success_msg);
              return valueMap['data']['url'];
            }
            else {
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
              print("fn_AddOrderFun400 :::${valueMap['code']} ${valueMap['error']} ${valueMap['message']} ${valueMap['data']}");
              return "";
            }
          }
          else {

            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,
                "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
            print("fn_AddOrderFunStatusCode400 ::: ${response.statusCode} ");
            return "";
          }
        }
        else
        {
          return "";
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_AddOrderFunException ::: ${e} ");
        return "";
      }

    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_AddOrderFunException ::: checkInternet ");
      return "";
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_AddOrderFunException ::: ${e} ");
    return "";
  }
}

Future<bool?> SaveRate(BuildContext context,String rate ,String comment) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
      try {
        var lang= LanguageData.languageData;
        print(lang);
        var data = jsonEncode(<String, String>{
          'value': rate,
          "lang": lang,
          "customer_id":DelegateData.delegateData!.id.toString(),
          "comment":comment
        });
        final response = await Post_Data(reviews, data);
        print(response.body);
        if (response.statusCode == 200) {
          Map valueMap = jsonDecode(response.body);
          if (valueMap['code'] == 200) {
            print( " fn_Rate200 ::: ${valueMap['message']} ${valueMap['data']}");
            await AlertView(
                context, "success", Translations.of(context)!.Ok,Translations.of(context)!.success_msg);
            return true;
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,valueMap['data'].toString());
            print( "fn_Rate400 ::: ${valueMap['message']} ${valueMap['data']}");
            return false;
          }
        }
        else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
          print( "fn_LRatestatusCode400 ::: ${response.statusCode} ");
          return false;
        }
      }
      catch(e)
      {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            "Exception : ${e.toString()}");
        print( "fn_RateException ::: ${e} ");
        return false;
      }
    }
    else {
      await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          Translations.of(context)!.CheckInternet);
      print("fn_RateException ::: checkInternet ");
      return false;
    }
  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_RateException ::: ${e} ");
    return false;
  }
}


List<ServicesModel> GetServices()
{
  var data= <ServicesModel>[
    new ServicesModel(2, "وقود", "i3",false,
        [new ServicesDetailsModel(21, "خدمة 21 ", 10,false),
          new ServicesDetailsModel(22, "خدمة 22 ", 20,false),
          new ServicesDetailsModel(23, "خدمة 23 ", 30,false)]),
    new ServicesModel(3, "صيانة", "i4",false,
        [new ServicesDetailsModel(31, "خدمة 31 ", 10,false),
          new ServicesDetailsModel(32, "خدمة 32 ", 20,false),
          new ServicesDetailsModel(33, "خدمة 33 ", 30,false)]),
    new ServicesModel(1, "غسيل سيارة", "i5",false,
        [new ServicesDetailsModel(11, "خدمة 11 ", 10,false),
          new ServicesDetailsModel(12, "خدمة 12 ", 20,false),
          new ServicesDetailsModel(13, "خدمة 13 ", 30,false)]),
    new ServicesModel(4, "تغيير زيت", "i6",false,
        [new ServicesDetailsModel(41, "خدمة 41 ", 10,false)
          ,new ServicesDetailsModel(42, "خدمة 42 ", 20,false),
          new ServicesDetailsModel(43, "خدمة 43 ", 30,false)]),
    new ServicesModel(5, "قطع غيار", "i2",false,
        [new ServicesDetailsModel(51, "خدمة 51 ", 10,false),
          new ServicesDetailsModel(52, "خدمة 52 ", 20,false),
          new ServicesDetailsModel(53, "خدمة 53 ", 30,false)]),
    new ServicesModel(6, "سوبر ماركت", "i1",false,
        [new ServicesDetailsModel(61, "خدمة 61 ", 10,false),
          new ServicesDetailsModel(62, "خدمة 62 ", 20,false),
          new ServicesDetailsModel(63, "خدمة 63 ", 30,false)]),
  ];
  return data;
}