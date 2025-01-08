import 'package:nostr_dart/nostr_dart.dart';

class NostrDart {
  NostrDart._();

  static SignatureVerifier get signatureVerifier => _signatureVerifier;
  static NostrDartLogger? get logger => _logger;

  static SignatureVerifier _signatureVerifier = SchnorrSignatureVerifier();
  static NostrDartLogger? _logger;

  static void configure({
    SignatureVerifier? signatureVerifier,
    NostrDartLogger? logger,
  }) {
    if (signatureVerifier != null) _signatureVerifier = signatureVerifier;
    if (logger != null) _logger = logger;
  }
}
