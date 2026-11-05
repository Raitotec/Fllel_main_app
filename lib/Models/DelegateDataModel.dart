class DelegateDataModel {
  int? id;
  int? fuelBeneficiaryId;
  String? accountType;
  String? name;
  String? mobile;
  String? verificationLogin;
  bool isRegistrationVerification = false;
  String? email;
  String? employeeNumber;
  Map<String, dynamic>? company;
  Map<String, dynamic>? customer;
  Map<String, dynamic>? contract;
  String? message;
  bool? requiresVerification;
  String? token;
  Map<String, dynamic> _data = {};

  DelegateDataModel({this.id, this.name, this.mobile, this.email, this.token});

  DelegateDataModel.fromJson(Map<String, dynamic> json) {
    _data = Map<String, dynamic>.from(json);
    fuelBeneficiaryId = int.tryParse(json['fuel_beneficiary_id'].toString());
    id = fuelBeneficiaryId ?? int.tryParse(json['id'].toString()) ?? -1;
    accountType = json['account_type']?.toString();
    employeeNumber = json['employee_number']?.toString();
    company = json['company'] is Map ? Map<String, dynamic>.from(json['company']) : null;
    customer = json['customer'] is Map ? Map<String, dynamic>.from(json['customer']) : null;
    contract = json['contract'] is Map ? Map<String, dynamic>.from(json['contract']) : null;
    requiresVerification = json['requires_verification'] ?? true;
    message = json['message']?.toString() ?? '';
    mobile = json['mobile']?.toString() ?? '';
    email = json['email']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    final tokenValue = json['token'] ?? json['access_token'];
    token = tokenValue is String ? tokenValue.trim() : '';
  }

  Map<String, dynamic> toJson() {
    return {
      ..._data,
      'id': id,
      'fuel_beneficiary_id': fuelBeneficiaryId,
      'account_type': accountType,
      'name': name,
      'mobile': mobile,
      'email': email,
      'employee_number': employeeNumber,
      'company': company,
      'customer': customer,
      'contract': contract,
      'message': message,
      'requires_verification': requiresVerification,
      'token': token,
    };
  }
}
