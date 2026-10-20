
class CompanyModel {
  int? id;
  String? name;
  String? nameEn;
  String? logo;
  String? baseUrl;
  String? petrolstation_base_url;
  String? market;


  CompanyModel({this.id, this.name, this.nameEn, this.logo, this.baseUrl, this.petrolstation_base_url,this.market});

  CompanyModel.fromJson(Map<String, dynamic> json) {
   // id = json['id'];
    name = json['name'];
    nameEn = json['name_en'];
    logo = json['logo'];
   // baseUrl = json['base_url'];
    petrolstation_base_url = json['petrolstation_base_url'];
   // market = json['market'];
    //market="0";
  // petroStation="0";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['name_en'] = this.nameEn;
    data['logo'] = this.logo;
    data['base_url'] = this.baseUrl;
    return data;
  }
}