class OrderModel {
  String? customerId;
  String? totalCost;
  String? date;
  String? inStation;
  String? address;
  String? lat;
  String? lng;
  String? status;
  String? lang;
  List<DetailsOrderModel>? details;

  OrderModel(
      {this.customerId,
        this.totalCost,
        this.date,
        this.inStation,
        this.address,
        this.lat,
        this.lng,
        this.status,
        this.details});

  OrderModel.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    totalCost = json['total_cost'];
    date = json['date'];
    inStation = json['in_station'];
    address = json['address'];
    lat = json['lat'];
    lng = json['lng'];
    status = json['status'];
    if (json['details'] != null) {
      details = <DetailsOrderModel>[];
      json['details'].forEach((v) {
        details!.add(new DetailsOrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_id'] = this.customerId;
    data['total_cost'] = this.totalCost;
    data['date'] = this.date;
    data['in_station'] = this.inStation;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['status'] = this.status;
    data['lang']=this.lang;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailsOrderModel
{

  String? productId;
  String? quantity;
  String? cost;

  DetailsOrderModel({this.productId, this.quantity, this.cost});

  DetailsOrderModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    quantity = json['quantity'];
    cost = json['cost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['cost'] = this.cost;
    return data;
  }
}