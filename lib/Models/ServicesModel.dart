import '../Shared_Data/LanguageData.dart';

class ServicesModel {
  int? id;
  String? name;
  String? img;
  String? icon;
  String? desc;
  String? type;//1out 0home
  bool? selected;
  List<ServicesDetailsModel> details=<ServicesDetailsModel>[];

  @override
  String toString() {
    if(name != null && name!.isNotEmpty)
      return name!;
    else
      return"";// Return the property you want to display
  }

  ServicesModel(this.id, this.name, this.icon,this.selected,this.details);

  ServicesModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'] != null?json['name'] :"";
      img = json['image']!= null?json['image'] :"";
      icon = json['icon']!= null?json['icon'] :"";
      if(LanguageData.languageData=="ar")
      {
        desc=json['desc_ar']!=null?json['desc_ar']:"";
      }
      else
      {
        desc=json['desc_en']!=null?json['desc_en']:"";
      }
      selected = false;
      if (json['details'] != null) {
        details = <ServicesDetailsModel>[];
        json['details'].forEach((v) {
          details!.add(new ServicesDetailsModel.fromJson(v));
        });
      }
    }
    catch(e)
    {
      print("1");
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.icon;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class ServicesDetailsModel {
  int? id;
  String? name;
  double? price;
  double? quantity;
  bool? selected;

  double get_total()
  {
    // double mod = pow(10.0, 2);
    var value= quantity!* price!;
    return value;
    //  return ((value * mod).round().toDouble() / mod);
  }
  ServicesDetailsModel(this.id, this.name, this.price, this.selected);

  ServicesDetailsModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['product_id'];
      name = json['name'];
      quantity = 0;
      price = double.tryParse( json['cost'].toString());
      selected = false;
    }
    catch(e)
    {
      print("2");
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.id;
    data['name'] = this.name;
    //data['image'] = this.image;
    data['cost'] = this.price;
    return data;
  }
}