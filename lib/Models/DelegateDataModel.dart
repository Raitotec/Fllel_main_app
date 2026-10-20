
import 'package:shared_preferences/shared_preferences.dart';

class DelegateDataModel {
  int? id;
  String? name;
  String? mobile;
  String? email;
  String? message;
  bool? requiresVerification;
  String? token;

  DelegateDataModel({this.id, this.name, this.mobile, this.email,this.token});

  DelegateDataModel.fromJson(Map<String, dynamic> json) {
    requiresVerification = json['requires_verification']??true;
    message = json['message']??"";
    mobile = json['mobile'].toString()??"";
    email = json['email'].toString()??"";
    id = int.tryParse(json['id'].toString())??-1;
    name = json['name'].toString()??"";
    token = json['token'].toString()??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    return data;
  }
}


