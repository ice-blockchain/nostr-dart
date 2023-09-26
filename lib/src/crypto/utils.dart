import 'dart:convert';
import 'dart:math';

import 'package:bip340/bip340.dart' as bip340;
import 'package:crypto/crypto.dart' as crypto;

final _secureRandom = Random.secure();

String hexedRandomBytes(int numberOfBytes) {
  final StringBuffer sb = StringBuffer();
  for (var i = 0; i < numberOfBytes; i++) {
    sb.write(_secureRandom.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

String sha256(String input) {
  return crypto.sha256.convert(utf8.encode(input)).toString();
}

String getBip340PublicKey(String privateKey) {
  return bip340.getPublicKey(privateKey);
}

String signBip340({
  required String message,
  required String privateKey,
  String? aux,
}) {
  return bip340.sign(
    privateKey,
    message,
    aux ?? hexedRandomBytes(32),
  );
}

bool verifyBip340Signature({
  required String signature,
  required String message,
  required String publicKey,
}) {
  return bip340.verify(publicKey, message, signature);
}
