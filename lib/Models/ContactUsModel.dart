class ContactUsModel {
  String? whatsappNumber;
  String? siteLink;


  ContactUsModel.fromJson(Map<String, dynamic> json) {

    whatsappNumber = json['whatsapp'] ?? "";
    siteLink = json['website'] ?? "";
  }

  ContactUsModel(this.whatsappNumber, this.siteLink);
}

