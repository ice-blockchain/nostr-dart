import 'package:nostr_dart/src/crypto/utils.dart';

/// Encapsulation of crypto-related tasks.
///
/// Signatures, public key, and encodings are done according to the
/// [Schnorr signatures standard for the curve secp256k1](https://bips.xyz/340).
class KeyStore {
  /// 32-bytes lowercase hex-encoded public key.
  /// Used to encrypt messages and verify signatures.
  /// Can be shared with anyone.
  final String publicKey;

  /// 32-bytes lowercase hex-encoded private key.
  /// Used to decrypt messages and generate message signatures.
  /// Must be kept secret.
  final String privateKey;

  /// Produces the [KeyStore] from a private key.
  ///
  /// Generates a public key from a given private key.
  /// [See more](https://bips.xyz/340#public-key-generation)
  factory KeyStore.fromPrivate(String privateKey) {
    if (privateKey.length != 64) {
      throw ArgumentError('privateKey', 'Length must be 64');
    }

    return KeyStore._(
      privateKey: privateKey,
      publicKey: getBip340PublicKey(privateKey),
    );
  }

  /// Produces [KeyStore] from scratch.
  ///
  /// Generates a new key pair (public + private keys).
  factory KeyStore.generate() {
    return KeyStore.fromPrivate(hexedRandomBytes(32));
  }

  KeyStore._({
    required this.privateKey,
    required this.publicKey,
  });

  /// Generates a schnorr signature using the BIP-340 scheme.
  ///
  /// It returns the signature as a string of 64 bytes hex-encoded.
  String sign({required String message}) {
    return signBip340(message: message, privateKey: privateKey);
  }

  @override
  String toString() {
    return "KeyStore privateKey:$privateKey publicKey:$publicKey";
  }

  /// Verifies a schnorr signature using the BIP-340 scheme.
  ///
  /// It returns true if the signature is valid, false otherwise.
  static bool verifySignature({
    required String signature,
    required String message,
    required String publicKey,
  }) {
    return verifyBip340Signature(
      signature: signature,
      publicKey: publicKey,
      message: message,
    );
  }
}
