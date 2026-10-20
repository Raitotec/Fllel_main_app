class RequestsModel {
  int? id;
  String? totalCost;
  String? date;
  String? status;
  int? inStation;
  int? customerId;
  String? address;
  String? lng;
  String? lat;
  List<RequestsDetails>? details;
  String? url;

  RequestsModel(
      {this.id,
        this.totalCost,
        this.date,
        this.status,
        this.inStation,
        this.customerId,
        this.address,
        this.lng,
        this.lat,
        this.details});

  RequestsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalCost = json['total_cost'];
    date = json['date'];
    status = json['status'];
    inStation = json['in_station'];
    customerId = json['customer_id'];
    address = json['address'];
    lng = json['lng'];
    lat = json['lat'];
    url = json['url']!=null?json['url']:"";
    if (json['details'] != null) {
      details = <RequestsDetails>[];
      json['details'].forEach((v) {
        details!.add(new RequestsDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['total_cost'] = this.totalCost;
    data['date'] = this.date;
    data['status'] = this.status;
    data['in_station'] = this.inStation;
    data['customer_id'] = this.customerId;
    data['address'] = this.address;
    data['lng'] = this.lng;
    data['lat'] = this.lat;
    if (this.details != null) {
      data['details'] = this.details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RequestsDetails {
  int? id;
  int? cartId;
  String? cost;
  String? quantity;
  int? productId;
  String? productName;

  RequestsDetails(
      {this.id,
        this.cartId,
        this.cost,
        this.quantity,
        this.productId,
        this.productName});

  RequestsDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cartId = json['cart_id'];
    cost = json['cost'];
    quantity = json['quantity'].toString();
    productId = json['product_id'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cart_id'] = this.cartId;
    data['cost'] = this.cost;
    data['quantity'] = this.quantity;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    return data;
  }
}