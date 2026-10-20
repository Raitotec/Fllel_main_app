
class PinDataModel {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? rate;
  String? mail;
  List<String> images=[];
  double lng=0;
  double lat=0;
  String? cityId;
  String? region_id;


  @override
  String toString() {
    if(name != null && name!.isNotEmpty)
      return name!;
    else
      return"";// Return the property you want to display
  }
  PinDataModel(this.id, this.name,
      this.address,this.phone,this.rate,
      this.lat,this.lng,this.images ,this.mail);
  PinDataModel.fromJson(Map<String, dynamic> json) {

    id = json['id'] != null ?json['id'] :0;
    name = json['name'] != null ?json['name']:"";
    address = json['address'] != null ?json['address']:"";
    phone = json['phone'] != null ?json['phone']:"";
    mail = json['email'] != null ?json['email']:"";
    if(json['lat'] != null)
    {
      var x= double.tryParse( json['lat'].toString());
      if(x!=null)
        lat=x;
      else
        lat=0;
    }
    else
    {
      lat=0;
    }
    if(json['lng'] != null)
    {
      var x= double.tryParse( json['lng'].toString());
      if(x!=null)
        lng=x;
      else
        lng=0;
    }
    else
    {
      lng=0;
    }

    rate = json['rate'] != null ?json['rate'].toString():"0";
    images = json['image'].cast<String>();
    cityId = json['cityId'] != null ?json['cityId'].toString():"";
    region_id = json['region_id'] != null ?json['region_id'].toString():"";

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['email'] = this.mail;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['rate'] = this.rate;
    data['image'] = this.images;
    return data;
  }
}