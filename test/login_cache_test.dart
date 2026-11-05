import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('access_token is normalized and survives serialization', () {
    final account = DelegateDataModel.fromJson({
      'fuel_beneficiary_id': 1, 'access_token': ' test-token ',
    });
    expect(account.token, 'test-token');
    expect(DelegateDataModel.fromJson(account.toJson()).token, 'test-token');
    expect(DelegateDataModel.fromJson({'token': null}).token, '');
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    DelegateData.delegateData = null;
  });

  test('fuel login survives cache reload and logout clears it', () async {
    final data = {
      'fuel_beneficiary_id': 1,
      'account_type': 'company_employee',
      'name': 'Test employee',
      'mobile': '0540000000',
      'email': 'test@example.com',
      'employee_number': 'M001',
      'company': {'id': 3, 'name': 'Test company'},
      'customer': null,
      'contract': {'id': 1, 'contract_number': 'FC-2026-TEST', 'ends_on': '2027-11-01'},
      'token': 'test-token',
      'requires_verification': true,
    };
    final account = DelegateDataModel.fromJson(data);
    expect(account.id, 1);
    expect(account.requiresVerification, isTrue);
    await saveDelegateData(account);
    DelegateData.delegateData = null;
    final restored = await getDelegateData();
    expect(restored!.toJson(), account.toJson());
    expect(restored.company!['id'], 3);
    expect(restored.customer, isNull);
    await removeDelgateDate();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('delegate_data'), isFalse);
    expect(prefs.containsKey('delegate_token'), isFalse);
    expect(DelegateData.delegateData, isNull);
  });

  test('individual account handles nulls and keeps legacy cache readable', () async {
    final account = DelegateDataModel.fromJson({
      'fuel_beneficiary_id': 2, 'account_type': 'individual',
      'company': null, 'contract': null, 'customer': {'id': 4},
    });
    await saveDelegateData(account);
    final restored = await getDelegateData();
    expect(restored!.id, 2);
    expect(restored.company, isNull);
    expect(restored.contract, isNull);
    expect(restored.customer!['id'], 4);
    expect(restored.token, '');
    SharedPreferences.setMockInitialValues({'delegateId': 5, 'delegate_token': 'legacy'});
    final legacy = await getDelegateData();
    expect(legacy!.id, 5);
    expect(legacy.token, 'legacy');
  });
}
