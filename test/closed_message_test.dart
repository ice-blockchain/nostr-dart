import 'dart:convert';

import 'package:nostr_dart/src/model/closed_message.dart';
import 'package:test/test.dart';

void main() {
  group('Closed Message', () {
    const String subscriptionId = '0000000000000000';
    const String eventMessage = 'error: could not connect to the database';
    const String rawEvent = '["CLOSED","$subscriptionId","$eventMessage"]';

    test('might be instantiated with unnamed constructor', () {
      final ClosedMessage message = ClosedMessage(
        subscriptionId: subscriptionId,
        message: eventMessage,
      );
      expect(message.runtimeType, equals(ClosedMessage));
      expect(message.message, equals(eventMessage));
    });

    test('might be instantiated with fromJson constructor', () {
      final ClosedMessage message =
          ClosedMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(ClosedMessage));
      expect(message.subscriptionId, equals(subscriptionId));
      expect(message.message, equals(eventMessage));
    });

    test('might be stringified to a raw message with toString method', () {
      final ClosedMessage message =
          ClosedMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
