import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../Shared_Data/LanguageData.dart';
import '../my_app.dart';


class ScopeModelWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(model: AppModel(), child: MyApp());
  }
}

class AppModel extends Model {
  Locale _appLocale = Locale('ar');
  Locale get appLocal => _appLocale ;

  void changeDirection() {
    print(_appLocale);
    if (_appLocale == Locale("ar")) {
      _appLocale = Locale("en");
      saveLanguageData("en");
    } else {
      _appLocale = Locale("ar");
      saveLanguageData("ar");
    }
    notifyListeners();
  }
}
