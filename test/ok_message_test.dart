import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Ok Message', () {
    const String eventId =
        'd6616d250e6b2fea2c1d74565f264b7295bd51ad7e879c7b9c047fa719eb3aad';
    const String eventMessage = 'duplicate: already have this event';
    const bool accepted = true;
    const String rawEvent = '["OK","$eventId",$accepted,"$eventMessage"]';

    test('might be instantiated with unnamed constructor', () {
      final OkMessage message = OkMessage(
        eventId: eventId,
        accepted: accepted,
        message: eventMessage,
      );
      expect(message.runtimeType, equals(OkMessage));
      expect(message.message, equals(eventMessage));
    });

    test('might be instantiated with fromJson constructor', () {
      final OkMessage message =
          OkMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(OkMessage));
      expect(message.eventId, equals(eventId));
      expect(message.accepted, equals(accepted));
      expect(message.message, equals(eventMessage));
    });

    test('might be stringified to a raw message with toString method', () {
      final OkMessage message =
          OkMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
