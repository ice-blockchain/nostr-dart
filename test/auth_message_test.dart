import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Auth Message', () {
    const String challenge = 'challenge-string-from-relay';
    final String rawEvent = jsonEncode(['AUTH', challenge]);

    test('can be instantiated with unnamed constructor', () {
      final AuthMessage message = AuthMessage(challenge: challenge);
      expect(message.runtimeType, equals(AuthMessage));
      expect(message.challenge, equals(challenge));
    });

    test('can be instantiated with fromJson constructor', () {
      final AuthMessage message =
          AuthMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(AuthMessage));
      expect(message.challenge, equals(challenge));
    });

    test('can be converted to a raw message with toString method', () {
      final AuthMessage message =
          AuthMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
