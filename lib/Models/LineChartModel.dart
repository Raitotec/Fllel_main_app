import 'package:babco/Shared_Data/LanguageData.dart';

class CityModel{
  int? id;
  String? nameAr;
  String? nameEn;


  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['nameAr'] != null ?json['nameAr'].toString():"";
    nameEn = json['nameEn'] != null ?json['nameEn'].toString():"";
  }

  CityModel(this.id, this.nameAr,this.nameEn );
  String? getName()
  {
    if( LanguageData.languageData=="ar")
    {
      return nameAr;
    }
    else
    {
      return nameEn;
    }
  }
}