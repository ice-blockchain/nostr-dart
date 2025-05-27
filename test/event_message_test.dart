import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/utils/date.dart';
import 'package:test/test.dart';

void main() {
  NostrDart.configure();
  group('Event Message', () {
    const String privateKey = 'ab67ae56758c77096a65e7f2ff41aaf8fcddd0817da971895885848fadf6eef9';
    const String publicKey = '9e65c9a8a30778440065603a58aa5ab07d14ffd870a14c6c76b63cdea96b8ba0';
    const String subscriptionId = '3497816659629849';
    const String content = 'Message Content';
    const int createdAt = 1676148923;
    const int createdAtMicroseconds = createdAt * 1000 * 1000;
    const String eventId = 'f98bfdefb71b14713505947eb39b84f006e44b68d73ab1d223c601f3d22a7baf';
    const String sig =
        '882d2d950f5cd2596b236525d4004157b971901e4f13f388d2692b406c099247a4d9a75ae26212f48c67a6d71c4bccba94b317353f12b9e510e60c96cb773875';
    const int kind = 1;
    const String tagE = '656edc6216203b1a91f129e4166bedb1b7c856825152d6709e74c46eb94d047b';
    const String tagP = '84dee6e676e5bb67b4ad4e042cf70cbd8681155db535942fcc6a0533858a7240';
    const String tags = '[["e","$tagE"],["p","$tagP"]]';
    const payload =
        '{"id":"$eventId","pubkey":"$publicKey","created_at":$createdAt,"kind":$kind,"tags":$tags,"content":"$content","sig":"$sig"}';
    const payloadMicroseconds =
        '{"id":"$eventId","pubkey":"$publicKey","created_at":$createdAtMicroseconds,"kind":$kind,"tags":$tags,"content":"$content","sig":"$sig"}';
    const String rawEvent = '["EVENT","$subscriptionId",$payload]';
    const String rawEventMicroseconds = '["EVENT","$subscriptionId",$payloadMicroseconds]';

    test('might be instantiated with unnamed constructor', () {
      final EventMessage message = EventMessage(
        id: eventId,
        pubkey: publicKey,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(createdAt),
        kind: kind,
        tags: const [
          ['e', tagE],
          ['p', tagP],
        ],
        content: content,
        sig: sig,
      );
      expect(message.runtimeType, equals(EventMessage));
      expect(message.id, equals(eventId));
      expect(message.pubkey, equals(publicKey));
      expect(message.tags[0][1], equals(tagE));
      expect(message.content, equals(content));
      expect(message.kind, equals(kind));
      expect(
        message.createdAt,
        equals(DateTime.fromMicrosecondsSinceEpoch(createdAt)),
      );
    });

    test('might be instantiated with fromData constructor', () async {
      final KeyStore keyStore = KeyStore.fromPrivate(privateKey);
      final EventMessage message = await EventMessage.fromData(
        signer: keyStore,
        kind: kind,
        content: content,
        createdAt: fromTimestamp(createdAt),
        tags: const [
          ['e', tagE],
          ['p', tagP],
        ],
      );
      expect(message.runtimeType, equals(EventMessage));
      expect(message.id, equals(eventId));
      expect(message.pubkey, equals(publicKey));
      expect(message.tags[0][1], equals(tagE));
      expect(message.content, equals(content));
      expect(message.kind, equals(kind));
      expect(
        message.createdAt,
        equals(DateTime.fromMicrosecondsSinceEpoch(createdAtMicroseconds)),
      );
    });

    test('might be instantiated with fromJson constructor', () {
      final EventMessage message = EventMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.runtimeType, equals(EventMessage));
      expect(message.id, equals(eventId));
      expect(message.pubkey, equals(publicKey));
      expect(message.subscriptionId, equals(subscriptionId));
      expect(message.tags[0][1], equals(tagE));
      expect(message.content, equals(content));
      expect(message.kind, equals(kind));
      expect(
        message.createdAt,
        equals(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)),
      );
    });

    test('might be instantiated with fromJson constructor with microseconds createdAt', () {
      final EventMessage message =
          EventMessage.fromJson(jsonDecode(rawEventMicroseconds) as List<dynamic>);
      expect(message.runtimeType, equals(EventMessage));
      expect(message.id, equals(eventId));
      expect(message.pubkey, equals(publicKey));
      expect(message.subscriptionId, equals(subscriptionId));
      expect(message.tags[0][1], equals(tagE));
      expect(message.content, equals(content));
      expect(message.kind, equals(kind));
      expect(
        message.createdAt,
        equals(DateTime.fromMicrosecondsSinceEpoch(createdAtMicroseconds)),
      );
    });

    test('might be stringified to a raw message with toString method', () {
      final EventMessage message = EventMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEventMicroseconds));
    });

    test('validate() should return true for a valid event', () async {
      final eventValid =
          await EventMessage.fromJson(jsonDecode(rawEventMicroseconds) as List<dynamic>).validate();
      expect(eventValid, isTrue);
    });

    test('validate() should return false for event with incorrect id', () async {
      final eventValid = await EventMessage.fromJson(
        jsonDecode(rawEvent.replaceFirst(eventId, '123')) as List<dynamic>,
      ).validate();
      expect(eventValid, isFalse);
    });

    test('validate() should return false for event with incorrect signature', () async {
      final eventValid = await EventMessage.fromJson(
        jsonDecode(rawEvent.replaceFirst(eventId, '123')) as List<dynamic>,
      ).validate();
      expect(eventValid, isFalse);
    });

    test('tags are normalized when using fromData constructor', () async {
      final KeyStore keyStore = KeyStore.fromPrivate(privateKey);
      final EventMessage message = await EventMessage.fromData(
        signer: keyStore,
        content: '',
        tags: [
          ["e", "id", "", ""],
          ["empty", "", ""],
          ["e", "id", "", "pubkey"],
          ["single"],
        ],
        kind: kind,
      );
      expect(message.tags.length, equals(3));
      expect(message.tags[0], ["e", "id"]);
      expect(message.tags[1], ["e", "id", "", "pubkey"]);
      expect(message.tags[2], ["single"]);
    });
  });
}
