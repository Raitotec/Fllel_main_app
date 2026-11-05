import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Models/DelegateDataModel.dart';

class DelegateData {
  static DelegateDataModel? delegateData= null;
}

saveDelegateData(DelegateDataModel obj)async
{
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('delegate_data', jsonEncode(obj.toJson()));
  await prefs.setInt("delegateId", obj.id ?? -1);
  await prefs.setString("delegate_name", obj.name ?? '');
  await prefs.setString("delegate_email", obj.email ?? '');
  await prefs.setString("delegate_mobile", obj.mobile ?? '');
  await prefs.setString("delegate_token", obj.token ?? '');
  DelegateData.delegateData= obj;
  print( DelegateData.delegateData!.name);
  print( DelegateData.delegateData!.id);
  print("saveDelegateData");
}


Future<DelegateDataModel?> getDelegateData()async
{
  try {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('delegate_data');
    if (cachedData != null) {
      final obj = DelegateDataModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(cachedData)));
      DelegateData.delegateData = obj;
      return obj;
    }
    var delegateId = prefs.getInt('delegateId') ?? -1;
    var delegate_name = prefs.getString('delegate_name') ?? null;
    var delegate_email = prefs.getString('delegate_email') ?? null;
    var delegate_mobile = prefs.getString('delegate_mobile') ?? null;
    var delegate_token = prefs.getString('delegate_token') ?? null;
    DelegateDataModel obj = new DelegateDataModel(
        id: delegateId,
        name: delegate_name,
        email: delegate_email,
        mobile: delegate_mobile,
        token: delegate_token
    );
    DelegateData.delegateData = obj;
    print(DelegateData.delegateData!.name);
    print(DelegateData.delegateData!.mobile);
    return obj;
  }
  catch(e){
    print("eeee"+e.toString());
    return null;
  }
}

removeDelgateDate()async
{
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('delegate_data');
    await prefs.remove('delegateId');
    await prefs.remove('delegate_name');
    await prefs.remove('delegate_email');
    await prefs.remove('delegate_mobile');
    await prefs.remove("delegate_token");
    DelegateData.delegateData = null;
  }
  catch(e)
  {
    DelegateData.delegateData = null;
  }
}
