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
    final encrypter = Encrypter(AES(_generateKey(key)));
    final iv = _generateIV();
    final encrypted = encrypter.encrypt(password, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  static String decryptPassword(String encrypted, String key) {
    final parts = encrypted.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypter = Encrypter(AES(_generateKey(key)));
    final decrypted = encrypter.decrypt64(parts[1], iv: iv);
    return decrypted;
  }
}