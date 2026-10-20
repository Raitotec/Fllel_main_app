

class RegionModel {
  int? id;
  String? nameAr;
  String? nameEn;
  List<CitiesModel>? cities;

  RegionModel({this.id, this.nameAr, this.nameEn, this.cities});

  RegionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
    if (json['cities'] != null) {
      cities = <CitiesModel>[];
      json['cities'].forEach((v) {
        cities!.add(new CitiesModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nameAr'] = this.nameAr;
    data['nameEn'] = this.nameEn;
    if (this.cities != null) {
      data['cities'] = this.cities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CitiesModel {
  int? id;
  String? nameAr;
  String? nameEn;

  CitiesModel({this.id, this.nameAr, this.nameEn});

  CitiesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameAr = json['nameAr'];
    nameEn = json['nameEn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nameAr'] = this.nameAr;
    data['nameEn'] = this.nameEn;
    return data;
  }
}