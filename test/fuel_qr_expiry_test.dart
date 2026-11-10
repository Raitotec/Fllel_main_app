import 'package:flutter_test/flutter_test.dart';
import 'package:babco/Shared_Data/QrEncryption.dart';

void main() {
  final now = DateTime.utc(2026, 11, 9, 10);
  test('accepts current code and rejects expired and future codes', () {
    final codec = FuelQrEncryption();
    final value = codec.encode(1, now: now);
    expect(codec.decode(value, now: now), 1);
    expect(codec.decode(value, now: now.add(const Duration(seconds: 29))), 1);
    expect(() => codec.decode(value, now: now.add(const Duration(seconds: 30))), throwsFormatException);
    expect(() => codec.decode(value, now: now.subtract(const Duration(seconds: 1))), throwsFormatException);
  });
  test('rejects legacy and modified codes and creates fresh ciphertext', () {
    final codec = FuelQrEncryption();
    final value = codec.encode(1, now: now);
    expect(codec.encode(1, now: now), isNot(value));
    expect(() => codec.decode(value.replaceFirst('FLF2', 'FLF1'), now: now), throwsFormatException);
    final parts = value.split('.');
    parts[2] = '${parts[2][0] == 'A' ? 'B' : 'A'}${parts[2].substring(1)}';
    expect(() => codec.decode(parts.join('.'), now: now), throwsFormatException);
  });
}
