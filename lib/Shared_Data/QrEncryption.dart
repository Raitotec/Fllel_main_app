import 'dart:convert';
import 'dart:typed_data';

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

/// Shared wire format for the customer and station applications.
/// Uses the encrypt package. Both applications must share this codec and key.
/// An embedded key hides the ID but can be extracted from the application.
class FuelQrEncryption {
  static const String _sharedKey = 'hOCj8SN+DBhYvGsnEsV7ArBcqZtYeezmfWz47Na9EJs=';
  static const String prefix = 'FLF2';
  final Encrypter _cipher;
  static final Uint8List _associatedData = Uint8List.fromList(utf8.encode(prefix));

  FuelQrEncryption([String? base64Key]) : _cipher = Encrypter(
      AES(_key(base64Key ?? _sharedKey), mode: AESMode.gcm));

  static Key _key(String value) {
    final bytes = base64Decode(value);
    if (bytes.length != 32) {
      throw ArgumentError('Fuel QR requires a 32-byte Base64 key');
    }
    return Key(bytes);
  }

  static const lifetime = Duration(seconds: 30);

  String encode(int beneficiaryId, {DateTime? now}) {
    if (beneficiaryId <= 0) throw ArgumentError('Invalid beneficiary ID');
    final nonce = IV.fromSecureRandom(12);
    final issuedAt = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final payload = jsonEncode({
      'beneficiary_id': beneficiaryId,
      'issued_at': issuedAt,
      'expires_at': issuedAt + lifetime.inMilliseconds,
    });
    final encrypted = _cipher.encrypt(payload,
        iv: nonce, associatedData: _associatedData);
    return '$prefix.${base64UrlEncode(nonce.bytes)}.${base64UrlEncode(encrypted.bytes)}';
  }

  /// Authenticate before returning the ID to the station application.
  /// Ciphertext includes the 16-byte GCM authentication tag at its end.
  int decode(String value, {DateTime? now}) {
    try {
      final parts = value.split('.');
      if (parts.length != 3 || parts.first != prefix || value.length > 512) {
        throw const FormatException('Invalid fuel QR');
      }
      final nonce = base64Url.decode(parts[1]);
      final encrypted = base64Url.decode(parts[2]);
      if (nonce.length != 12 || encrypted.length <= 16) {
        throw const FormatException('Invalid fuel QR');
      }
      final plaintext = _cipher.decrypt(Encrypted(encrypted),
          iv: IV(nonce), associatedData: _associatedData);
      final payload = jsonDecode(plaintext);
      if (payload is! Map) throw const FormatException('Invalid fuel QR');
      final id = payload['beneficiary_id'];
      final issuedAt = payload['issued_at'];
      final expiresAt = payload['expires_at'];
      final current = (now ?? DateTime.now()).millisecondsSinceEpoch;
      if (id is! int || id <= 0 || issuedAt is! int || expiresAt is! int ||
          expiresAt - issuedAt != lifetime.inMilliseconds ||
          current < issuedAt || current >= expiresAt) {
        throw const FormatException('Invalid or expired fuel QR');
      }
      return id;
    } catch (_) {
      throw const FormatException('Invalid fuel QR');
    }
  }
}
