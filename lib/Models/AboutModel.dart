import 'package:babco/Shared_Data/LanguageData.dart';

class AboutModel {
  String? name;
  String? description;

  AboutModel({this.name, this.description});

  AboutModel.fromJson(Map<String, dynamic> json) {
  name = json['name']!= null?json['name'].toString():"";
  description = json['description']!= null?json['description'].toString():"";
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['name'] = this.name;
  data['description'] = this.description;
  return data;
}
}


