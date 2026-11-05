class FuelCardData {
  const FuelCardData({required this.name, required this.employeeNumber, required this.available, required this.allowance, required this.fuel, required this.period, this.beneficiaryId, this.active = true, this.showStatus = true, this.amountBased = false, this.consumed, this.remainingPercentage, this.vehicle = const {}, this.contract = const {}, this.lastRefill, this.allowanceDetails = const {}});
  final int? beneficiaryId;
  final String name, employeeNumber, fuel, period;
  final double? available, allowance, consumed, remainingPercentage;
  final bool active, showStatus, amountBased;
  final Map<String, dynamic> vehicle, contract, allowanceDetails;
  final Map<String, dynamic>? lastRefill;
  double? get consumedValue => consumed ?? (allowance != null && available != null ? (allowance! - available!).clamp(0, double.infinity) : null);
  double get remainingRatio => remainingPercentage != null ? (remainingPercentage! / 100).clamp(0, 1) : (allowance != null && allowance! > 0 && available != null ? (available! / allowance!).clamp(0, 1) : 0);
  String get billingName => contract['billing_customer'] is Map ? contract['billing_customer']['name']?.toString() ?? '' : '';

  factory FuelCardData.fromJson(Map<String, dynamic> json) {
    final beneficiary = _map(json['beneficiary']);
    final vehicle = _map(json['vehicle']);
    final allowance = _map(json['allowance']);
    return FuelCardData(
      beneficiaryId: int.tryParse(beneficiary['id']?.toString() ?? ''),
      name: beneficiary['name']?.toString() ?? '',
      employeeNumber: beneficiary['employee_number']?.toString() ?? '',
      available: _number(allowance['remaining_amount']),
      allowance: _number(allowance['allocated_amount']),
      consumed: _number(allowance['consumed_amount']),
      remainingPercentage: _number(allowance['remaining_percentage']),
      fuel: vehicle['fuel_type']?.toString() ?? '',
      period: [allowance['starts_on'], allowance['ends_on']].where((v) => v != null).join(' — '),
      allowanceDetails: allowance,
      amountBased: true,
      showStatus: false,
      vehicle: vehicle,
      contract: _map(json['contract']),
      lastRefill: json['last_refill'] is Map ? _map(json['last_refill']) : null,
    );
  }
  static Map<String, dynamic> _map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : {};
  static double? _number(dynamic value) {
    final number = double.tryParse(value?.toString() ?? '');
    return number != null && number.isFinite ? number : null;
  }
}
