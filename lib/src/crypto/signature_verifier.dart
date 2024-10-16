import 'package:nostr_dart/src/crypto/utils.dart';

mixin SignatureVerifier {
  Future<bool> verify({
    required String signature,
    required String message,
    required String publicKey,
  });
}

class SchnorrSignatureVerifier with SignatureVerifier {
  SchnorrSignatureVerifier();

  /// Verifies a schnorr signature using the BIP-340 scheme.
  ///
  /// It returns true if the signature is valid, false otherwise.
  @override
  Future<bool> verify({
    required String signature,
    required String message,
    required String publicKey,
  }) async {
    return verifyBip340Signature(
      signature: signature,
      publicKey: publicKey,
      message: message,
    );
  }
}
