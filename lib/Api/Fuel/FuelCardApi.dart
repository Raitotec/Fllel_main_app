import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Models/FuelCardModel.dart';
import '../../Shared_View/AlertView.dart';
import '../../Shared_Data/DelegateData.dart';

Future<FuelCardData?> GetFuelCard(BuildContext context) async {
  try {
    final tokenPresent = (DelegateData.delegateData?.token ?? '').trim().isNotEmpty;
    print(DelegateData.delegateData?.token );
    final response = await Get_Data(fuel_card, null);
    debugPrint('Fuel card HTTP status: ${response.statusCode}; authorization token present: $tokenPresent');
    Map valueMap;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) throw const FormatException('Expected JSON object');
      valueMap = decoded;
    } on FormatException {
      debugPrint('Fuel card error response: ${response.body}');
      if (!context.mounted) return null;
      await AlertView(context, 'error', Translations.of(context)!.ErrorTitle,
          response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}');
      return null;
    }
    if (response.statusCode == 200 && valueMap['code'] == 200 && valueMap['data'] is Map) {
      return FuelCardData.fromJson(Map<String, dynamic>.from(valueMap['data']));
    }
    final message = (valueMap['message'] ?? valueMap['error'] ?? response.body).toString();
    debugPrint('Fuel card error response: ${response.body}');
    if (!context.mounted) return null;
    await AlertView(context, 'error', Translations.of(context)!.ErrorTitle, message);
  } catch (e) {
    debugPrint('Fuel card request failed: $e');
    if (!context.mounted) return null;
    await AlertView(context, 'error', Translations.of(context)!.ErrorTitle, e.toString());
  }
  return null;
}

Future<Map<String, dynamic>> GetFuelRefills(DateTime month, int page, String? status) async {
  final response = await Get_Data('customer/fuel/refills', <String, String>{
    'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
    'per_page': '15',
    'page': page.toString(),
    if (status != null) 'status': status,
  });
  final valueMap = jsonDecode(response.body);
  if (response.statusCode == 200 && valueMap is Map && valueMap['code'] == 200 && valueMap['data'] is Map) {
    return Map<String, dynamic>.from(valueMap['data']);
  }
  throw Exception(valueMap is Map ? (valueMap['message'] ?? valueMap['error'] ?? response.body).toString() : response.body);
}

Future<Map<String, dynamic>> GetFuelRefillDetails(String id) async {
  final response = await Get_Data('customer/fuel/refills/${Uri.encodeComponent(id)}', null);
  final valueMap = jsonDecode(response.body);
  if (response.statusCode == 200 && valueMap is Map && valueMap['code'] == 200 && valueMap['data'] is Map) {
    return Map<String, dynamic>.from(valueMap['data']);
  }
  throw Exception(valueMap is Map ? (valueMap['message'] ?? valueMap['error'] ?? response.body).toString() : response.body);
}
