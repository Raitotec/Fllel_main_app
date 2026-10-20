import 'package:flutter/material.dart';
//import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';

import '../Localization/Translations.dart';
import '../Shared_View/AlertView.dart';



Future<bool> checkVersion(BuildContext context) async {
  try {
    /*
    final _checker = AppVersionChecker();
    var value= await _checker.checkUpdate();
    print(value.canUpdate); //return true if update is available
    print(value.currentVersion); //return current app version
    print(value.newVersion); //return the new app version
    print(value.appURL); //return the app url
    print(value.errorMessage); //return error message if found else it will return null
    if(value.canUpdate)
    {

      await AlertView(
          context, "error", Translations.of(context)!.Please,
          Translations.of(context)!.LastVersion + "(" + value.currentVersion + " - " + (value.newVersion as String)+ ")",id: 1);
      return true;
    }
    else
    {
      return false;
    }*/
    return false;
  }
  catch (e) {

    await AlertView(
        context, "error", Translations.of(context)!.ErrorTitle,
        "Exception : ${e.toString()}");

    return false;
  }
}