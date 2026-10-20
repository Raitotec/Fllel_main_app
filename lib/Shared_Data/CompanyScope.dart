import 'package:shared_preferences/shared_preferences.dart';
import 'CompanyData.dart';
import 'DelegateData.dart';
import 'BalancePointData.dart';
import 'ServicesData.dart';

Future<void> selectCompanyScope(String code) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('active_company_code') == code) return;
  await removeDelgateDate();
  await removeCompanyDate();
  BalancePointData.Balance = '';
  BalancePointData.Point = '';
  ServicesData.serviceData = [];
  NewServicesData.serviceData = [];
  AddressData.addressData = '';
  AddressData.lat = 0;
  AddressData.lng = 0;
  await prefs.setString('active_company_code', code);
}
