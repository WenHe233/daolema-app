import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// 锁屏 PIN 的加盐哈希（纯函数，便于单测）。PIN 本身不落盘，只存盐 + sha256 哈希。
class PinHash {
  const PinHash(this.salt, this.hash);
  final String salt;
  final String hash;
}

String _randomSalt([int len = 16]) {
  final r = Random.secure();
  return base64Url.encode(List<int>.generate(len, (_) => r.nextInt(256)));
}

PinHash hashPin(String pin, [String? salt]) {
  final s = salt ?? _randomSalt();
  final digest = sha256.convert(utf8.encode('$s:$pin'));
  return PinHash(s, digest.toString());
}

bool verifyPin(String pin, String salt, String hash) =>
    hashPin(pin, salt).hash == hash;
