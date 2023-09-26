import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Notice Message', () {
    const String eventMessage = 'Something went wrong';
    const String rawEvent = '["NOTICE","$eventMessage"]';

    test('might be instantiated with unnamed constructor', () {
      final NoticeMessage message = NoticeMessage(message: eventMessage);
      expect(message.runtimeType, equals(NoticeMessage));
      expect(message.message, equals(eventMessage));
    });

    test('might be instantiated with fromJson constructor', () {
      final NoticeMessage message =
          NoticeMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(NoticeMessage));
      expect(message.message, equals(eventMessage));
    });

    test('might be stringified to a raw message with toString method', () {
      final NoticeMessage message =
          NoticeMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });
  });
}
