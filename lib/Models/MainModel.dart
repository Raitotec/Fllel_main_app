class MainModel {
  List<SlideImages>? slideImages;
  String? walletBalance;
  String? pointsBalance;
  List<OffersAndDiscounts>? offersAndDiscounts;

  MainModel({this.slideImages,
    this.walletBalance,
    this.pointsBalance,
    this.offersAndDiscounts,});

  MainModel.fromJson(Map<String, dynamic> json) {
    if (json['slide_images'] != null) {
      slideImages = <SlideImages>[];
      json['slide_images'].forEach((v) {
        slideImages!.add(new SlideImages.fromJson(v));
      });
    }
    walletBalance = json['wallet_balance']!= null?json['wallet_balance'].toString():"";
    pointsBalance = json['points_balance']!= null?json['points_balance'].toString():"";
    if (json['offers_and_discounts'] != null) {
      offersAndDiscounts = <OffersAndDiscounts>[];
      json['offers_and_discounts'].forEach((v) {
        offersAndDiscounts!.add(new OffersAndDiscounts.fromJson(v));
      });
    }

  }

}

class SlideImages {
  int? id;
  String? image;

  SlideImages({this.id, this.image});

  SlideImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image']!= null?json['image'].toString():"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    return data;
  }
}

class OffersAndDiscounts {
  int? id;
  String? name;
  String? discountPercentage;
  String? descriptionEn;
  String? descriptionAr;
  String? image;

  bool? selected;

  OffersAndDiscounts({this.id,
    this.name,
    this.discountPercentage,
    this.descriptionEn,
    this.descriptionAr,
    this.image});

  OffersAndDiscounts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']!= null?json['name'].toString():"";
    discountPercentage = json['discount_percentage']!= null?json['discount_percentage'].toString():"";
    descriptionEn = json['description_en']!= null?json['description_en'].toString():"";
    descriptionAr = json['description_ar']!= null?json['description_ar'].toString():"";
    image = json['image']!= null?json['image'].toString():"";
    selected=false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['discount_percentage'] = this.discountPercentage;
    data['description_en'] = this.descriptionEn;
    data['description_ar'] = this.descriptionAr;
    data['image'] = this.image;
    return data;
  }
}