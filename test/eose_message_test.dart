import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Eose Message', () {
    const String subscriptionId = '0000000000000000';
    const String rawEvent = '["EOSE","$subscriptionId"]';

    test('might be instantiated with unnamed constructor', () {
      final EoseMessage message = EoseMessage(subscriptionId: subscriptionId);
      expect(message.runtimeType, equals(EoseMessage));
      expect(message.subscriptionId, equals(subscriptionId));
    });

    test('might be instantiated with fromJson constructor', () {
      final EoseMessage message =
          EoseMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(EoseMessage));
      expect(message.subscriptionId, equals(subscriptionId));
    });

    test('might be stringified to a raw message with toString method', () {
      final EoseMessage message =
          EoseMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
