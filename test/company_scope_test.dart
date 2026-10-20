import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:babco/Shared_Data/CompanyScope.dart';

void main() {
  test('company switch removes the previous company and account', () async {
    SharedPreferences.setMockInitialValues({'active_company_code':'61', 'delegateId':20, 'delegate_token':'local-token', 'Company_petroStation':'https://old.example/api/'});
    await selectCompanyScope('133');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('active_company_code'), '133');
    expect(prefs.containsKey('delegateId'), isFalse);
    expect(prefs.containsKey('delegate_token'), isFalse);
    expect(prefs.containsKey('Company_petroStation'), isFalse);
  });
  test('restarting the same company preserves its login', () async {
    SharedPreferences.setMockInitialValues({'active_company_code':'133', 'delegateId':5, 'delegate_token':'local-token'});
    await selectCompanyScope('133');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('delegateId'), 5);
    expect(prefs.getString('delegate_token'), 'local-token');
  });
}
