import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

class CryptoUtils {
  static final _ivLength = 16; // 128 bits

  static Key _generateKey(String password) {
    final key = sha256.convert(utf8.encode(password)).bytes;
    return Key(Uint8List.fromList(key));
  }

  static IV _generateIV() {
    final iv = IV.fromLength(_ivLength);
    return iv;
  }

  static String encryptPassword(String password, String key) {
    final encrypter = Encrypter(AES(_generateKey(key), mode: AESMode.cbc, padding: 'PKCS7')); // Ensure AES 128 with PKCS7 padding
    final iv = _generateIV();
    final encrypted = encrypter.encrypt(password, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decryptPassword(String encrypted, String key) {
    final parts = encrypted.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted data format');
    }
    final iv = IV.fromBase64(parts[0]);
    final encrypter = Encrypter(AES(_generateKey(key), mode: AESMode.cbc, padding: 'PKCS7')); // Ensure AES 128 with PKCS7 padding
    try {
      final decrypted = encrypter.decrypt64(parts[1], iv: iv);
      return decrypted;
    } catch (e) {
      throw ArgumentError('Invalid or corrupted pad block');
    }
  }
}