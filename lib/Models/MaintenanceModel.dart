class MaintenanceModel
{
  int? id;
  String? name;


  MaintenanceModel(this.id, this.name);

  MaintenanceModel.fromJson(Map<String, dynamic> json) {

      id = json['id'];
      name = json['name'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class TransportationModel
{
  int? id;
  String? name;
  String? quantity;



  TransportationModel(this.id, this.name,this.quantity);

  TransportationModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    name = json['name'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    return data;
  }
}

class TransportationSaveModel
{
  String? name;
  String? phone;
  String? stationName;
  String? stationAddress;
  String? comment;
  String? latitude;
  String? longitude;
  List<TransportationModel>? details;



  TransportationSaveModel( this.name,this.phone,this.stationName,this.stationAddress,this.comment,this.longitude,this.latitude,this.details);

  TransportationSaveModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['stationName'] = this.stationName;
    data['stationAddress'] = this.stationAddress;
    data['comment'] = this.comment;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}