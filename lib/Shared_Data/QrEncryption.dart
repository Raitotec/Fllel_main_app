import 'dart:convert';

import 'package:encrypt/encrypt.dart';


class QrEncryption {

  // لازم يكون 32 حرف
  static final _key =
  Key.fromUtf8("Babco2026SecretKey12345678901234");

  // 16 حرف
  static final _iv = IV.fromUtf8("Babco1234567890");

  static final _encrypter = Encrypter(AES(_key));

  static String encrypt({
    required int userId,
    required String points,
    required String userName,
    required String userPhone,
    required String userEmail,
  }) {

    final jsonData = jsonEncode({
      "userId": userId,
      "points": points,
      "userName": userName,
      "userPhone": userPhone,
      "userEmail": userEmail,
      "time": DateTime.now().millisecondsSinceEpoch
    });

    return _encrypter.encrypt(jsonData, iv: _iv).base64;
  }

  static Map<String,dynamic> decrypt(String value){

    final decrypted =
    _encrypter.decrypt64(value, iv: _iv);

    return jsonDecode(decrypted);
  }

}