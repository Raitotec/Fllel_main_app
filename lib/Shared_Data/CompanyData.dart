
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/CompanyModel.dart';

class CompanyData {
  static CompanyModel? companyData= null;
}

saveCompanyData(CompanyModel obj)async
{
  final prefs = await SharedPreferences.getInstance();
 // prefs.setInt("Company_id", obj.id as int);
  prefs.setString("Company_name", obj.name as String);
  prefs.setString("Company_name_en", obj.nameEn as String);
  prefs.setString("Company_logo", obj.logo as String);
 // prefs.setString("Company_base_url", obj.baseUrl as String);
  prefs.setString("Company_petroStation", obj.petrolstation_base_url as String);
 // prefs.setString("Company_market", obj.market as String);
  CompanyData.companyData= obj;
  print(CompanyData.companyData!.logo);
}

Future<CompanyModel?> getCompanyData()async
{
  try {
    final prefs = await SharedPreferences.getInstance();
   // var Company_id = prefs.getInt('Company_id') ?? 0;
    var Company_name = prefs.getString('Company_name') ?? null;
    var Company_name_en = prefs.getString('Company_name_en') ?? null;
    var Company_logo = prefs.getString('Company_logo') ?? null;
    // var Company_logo = "https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxleHBsb3JlLWZlZWR8Mnx8fGVufDB8fHx8&w=1000&q=80";
   // var Company_base_url = prefs.getString('Company_base_url') ?? null;
    var Company_petroStation = prefs.getString('Company_petroStation') ?? null;
    //var Company_market = prefs.getString('Company_market') ?? null;
    // var Company_base_url = "http://raitotec.net/demo/delegates/api/";
    CompanyModel obj = new CompanyModel(
        name: Company_name,
        nameEn: Company_name_en,
        logo: Company_logo,
        petrolstation_base_url: Company_petroStation,
      );
    CompanyData.companyData = obj;
    return obj;
  }
  catch(e)
  {
    return null;
  }
}

removeCompanyDate()async
{
  final prefs = await SharedPreferences.getInstance();
 // prefs.remove('Company_id');
  prefs.remove('Company_name');
  prefs.remove('Company_name_en');
  prefs.remove('Company_logo');
 // prefs.remove('Company_base_url');
  prefs.remove('Company_petroStation');
 // prefs.remove('Company_market');
  CompanyData.companyData=null;
}
