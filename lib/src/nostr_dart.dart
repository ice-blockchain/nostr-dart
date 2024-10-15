import 'package:get_it/get_it.dart';
import 'package:logger/web.dart';
import 'package:nostr_dart/src/crypto/signature_verifier.dart';
import 'package:nostr_dart/src/logging.dart';

final GetIt getIt = GetIt.instance;

class NostrDart {
  NostrDart._();

  static void configure({
    SignatureVerifier? signatureVerifier,
    Level logLevel = NostrLogLevel.OFF,
  }) {
    setNostrLogLevel(logLevel);
    getIt.registerSingleton<SignatureVerifier>(signatureVerifier ?? SchnorrSignatureVerifier());
  }  
}
