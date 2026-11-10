import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Constans/Api_Services.dart';
import '../../Constans/Base_Url.dart';
import '../../Localization/Translations.dart';
import '../../Models/FuelCardModel.dart';
import '../../Shared_View/AlertView.dart';
import '../../Shared_Data/DelegateData.dart';

class FuelLoginRequired implements Exception {
  const FuelLoginRequired();
}

void _checkFuelAuthentication(int statusCode, dynamic body) {
  if (statusCode == 401 ||
      (body is Map && (body['code'].toString() == '401' ||
          body['message'] == 'Unauthenticated customer.'))) {
    throw const FuelLoginRequired();
  }
}

Future<FuelCardData?> GetFuelCard(BuildContext context, {bool silent = false}) async {
  try {
    final tokenPresent = (DelegateData.delegateData?.token ?? '').trim().isNotEmpty;
    final response = await Get_Data(fuel_card, null);
    debugPrint('Fuel card HTTP status: ${response.statusCode}; authorization token present: $tokenPresent');
    _checkFuelAuthentication(response.statusCode, null);
    Map valueMap;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) throw const FormatException('Expected JSON object');
      valueMap = decoded;
    } on FormatException {
      debugPrint('Fuel card error response: ${response.body}');
      if (!context.mounted || silent) return null;
      await AlertView(context, 'error', Translations.of(context)!.ErrorTitle,
          response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}');
      return null;
    }
    _checkFuelAuthentication(response.statusCode, valueMap);
    if (response.statusCode == 200 && valueMap['code'] == 200 && valueMap['data'] is Map) {
      return FuelCardData.fromJson(Map<String, dynamic>.from(valueMap['data']));
    }
    final message = (valueMap['message'] ?? valueMap['error'] ?? response.body).toString();
    debugPrint('Fuel card error response: ${response.body}');
    if (!context.mounted || silent) return null;
    await AlertView(context, 'error', Translations.of(context)!.ErrorTitle, message);
  } on FuelLoginRequired {
    rethrow;
  } catch (e) {
    debugPrint('Fuel card request failed: $e');
    if (!context.mounted || silent) return null;
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
  _checkFuelAuthentication(response.statusCode, null);
  final valueMap = jsonDecode(response.body);
  _checkFuelAuthentication(response.statusCode, valueMap);
  if (response.statusCode == 200 && valueMap is Map && valueMap['code'] == 200 && valueMap['data'] is Map) {
    return Map<String, dynamic>.from(valueMap['data']);
  }
  throw Exception(valueMap is Map ? (valueMap['message'] ?? valueMap['error'] ?? response.body).toString() : response.body);
}

Future<Map<String, dynamic>> GetFuelRefillDetails(String id) async {
  final response = await Get_Data('customer/fuel/refills/${Uri.encodeComponent(id)}', null);
  _checkFuelAuthentication(response.statusCode, null);
  final valueMap = jsonDecode(response.body);
  _checkFuelAuthentication(response.statusCode, valueMap);
  if (response.statusCode == 200 && valueMap is Map && valueMap['code'] == 200 && valueMap['data'] is Map) {
    return Map<String, dynamic>.from(valueMap['data']);
  }
  throw Exception(valueMap is Map ? (valueMap['message'] ?? valueMap['error'] ?? response.body).toString() : response.body);
}
