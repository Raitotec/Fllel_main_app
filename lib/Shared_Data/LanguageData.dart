
import 'package:shared_preferences/shared_preferences.dart';

class LanguageData {
  static String languageData= "ar";
}

saveLanguageData(String obj)async
{
  final prefs = await SharedPreferences.getInstance();

  prefs.setString("languageData", obj );
  LanguageData.languageData= obj;
}

Future<String> getLanguageData()async
{
  final prefs = await SharedPreferences.getInstance();
  var languageData = prefs.getString('languageData') ?? "ar";
  LanguageData.languageData= languageData;
  return languageData;
}


