import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Close Message', () {
    const String subscriptionId = '0000000000000000';
    const String rawEvent = '["CLOSE","$subscriptionId"]';

    test('might be instantiated with unnamed constructor', () {
      final CloseMessage message = CloseMessage(subscriptionId: subscriptionId);
      expect(message.runtimeType, equals(CloseMessage));
      expect(message.subscriptionId, equals(subscriptionId));
    });

    test('might be instantiated with fromJson constructor', () {
      final CloseMessage message =
          CloseMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(CloseMessage));
      expect(message.subscriptionId, equals(subscriptionId));
    });

    test('might be stringified to a raw message with toString method', () {
      final CloseMessage message =
          CloseMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
