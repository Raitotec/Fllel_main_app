import 'package:babco/Models/RequestsModel.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:babco/Constans/Base_Url.dart';
import 'package:babco/Shared_Data/DelegateData.dart';

import '../Constans/Api_Services.dart';
import '../Localization/Translations.dart';
import '../Models/PinDataModel.dart';
import '../Shared_Data/LanguageData.dart';
import '../Shared_Data/NetworkCheckData.dart';
import '../Shared_View/AlertView.dart';

Future<List<RequestsModel>?> GetRequests(BuildContext context ) async {
  try {

      bool InternetConntected = await hasNetwork();
      if (InternetConntected) {
        try {
          var lang = LanguageData.languageData;
          print(lang);
          var data = jsonEncode(<String, String>{
            "customer_id": DelegateData.delegateData!.id.toString(),
            "lang": lang,
          });
          final response = await Post_Data(mycarts, data);
          print(response.body);
          if (response.statusCode == 200) {
            Map valueMap = jsonDecode(response.body);
            if (valueMap['code'] == 200) {
              print(
                  " fn_GetRequests200 ::: ${valueMap['message']} ${valueMap['data']}");
              List<RequestsModel> obj = <RequestsModel>[];
              if (valueMap['data'] != null) {
                valueMap['data'].forEach((v) {
                  obj!.add(new RequestsModel.fromJson(v));
                });
              }

              return obj;
            }
            else {
              await AlertView(
                  context, "error", Translations.of(context)!.ErrorTitle,
                  valueMap['data'].toString());
              print(
                  "fn_GetRequests400 ::: ${valueMap['message']} ${valueMap['data']}");
              return null;
            }
          }
          else {
            await AlertView(
                context, "error", Translations.of(context)!.ErrorTitle,
                "error_statusCode ${response.statusCode} ${response
                    .reasonPhrase}");
            print("fn_GetRequestsstatusCode400 ::: ${response.statusCode} ");
            return null;
          }
        }
        catch (e) {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,
              "Exception : ${e.toString()}");
          print("fn_GetRequestsException ::: ${e} ");
          return null;
        }
      }
      else {
        await AlertView(
            context, "error", Translations.of(context)!.ErrorTitle,
            Translations.of(context)!.CheckInternet);
        print("fn_GetRequestsException ::: checkInternet ");
        return null;
      }



  }
  catch (e) {
    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");
    print("fn_GetRequestsException ::: ${e} ");
    return null;
  }
}

/*
List<RequestsModel> GetRequests()
{
  var data= <RequestsModel>[
   new RequestsModel( id: 1,
       totalCost: "50.00",
       date: "2023-10-01",
       status:"تحت التنفيذ",
       inStation: 1,
       customerId: 1,
       address: "المنصوره-الدقهليه-",
       lng: "5455664646",
       lat: "1122355445",
       details: <RequestsDetails>[new RequestsDetails(id: 1, cartId: 1,
         cost: "30.00",
         quantity: 2,
         productId: 1,
         productName:" وقود91"
       ),new RequestsDetails(id: 1, cartId: 1,
           cost: "30.00",
           quantity: 2,
           productId: 1,
           productName:" وقود91"
       ),new RequestsDetails(id: 1, cartId: 1,
           cost: "30.00",
           quantity: 2,
           productId: 1,
           productName:" وقود91"
       )]),
    new RequestsModel( id: 2,
        totalCost: "50.00",
        date: "2023-10-01",
        status:"تحت التنفيذ",
        inStation: 1,
        customerId: 1,
        address: "المنصوره-الدقهليه-",
        lng: "5455664646",
        lat: "1122355445",
        details: <RequestsDetails>[new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        ),new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        ),new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        )]),
    new RequestsModel( id: 3,
        totalCost: "50.00",
        date: "2023-10-01",
        status:"تحت التنفيذ",
        inStation: 1,
        customerId: 1,
        address: "المنصوره-الدقهليه-",
        lng: "5455664646",
        lat: "1122355445",
        details: <RequestsDetails>[new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        ),new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        ),new RequestsDetails(id: 1, cartId: 1,
            cost: "30.00",
            quantity: 2,
            productId: 1,
            productName:" وقود91"
        )])
  ];
  return data;
}*/