import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Models/DelegateDataModel.dart';
import '../../Shared_Data/NetworkCheckData.dart';
import '../../Shared_View/AlertView.dart';

Future<DelegateDataModel?> Login(
    BuildContext context, String loginName, String password) async {
  try {
    bool InternetConntected = await hasNetwork();
    if (InternetConntected) {
  try {
    var data = jsonEncode(<String, String>{
      'login': loginName,
      'password': password,
      'device_name': Platform.operatingSystem,
    });

    final response = await Post_Data(login, data);
    debugPrint('Login response status: ${response.statusCode}');
  //  if (response.statusCode == 200) {
      Map valueMap = jsonDecode(response.body);
      if (valueMap['code'] == 200) {
        final loginData = Map<String, dynamic>.from(valueMap['data']);
        debugPrint('Login response fields: ${valueMap.keys.join(', ')}');
        debugPrint('Login data fields: ${loginData.keys.join(', ')}');
        loginData['token'] = loginData['token'] ?? loginData['access_token']
            ?? valueMap['token'] ?? valueMap['access_token'];
        var obj= DelegateDataModel.fromJson(loginData);
        debugPrint('Login token received: ${(obj.token ?? '').isNotEmpty}');
      //  await saveDelegateData(obj);

        return obj;
      }
      else {
          await AlertView(
              context, "error", Translations.of(context)!.ErrorTitle,valueMap['message'].toString());
        print( "fn_Login400 ::: ${valueMap['message']} ${valueMap['data']}");
        return null;
      }
    /*}
    else {
    await AlertView(
          context, "error", Translations.of(context)!.ErrorTitle,
          "error_statusCode ${response.statusCode} ${response.reasonPhrase}");
      print( "fn_LoginstatusCode400 ::: ${response.statusCode} ");
      return null;
    }*/
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



