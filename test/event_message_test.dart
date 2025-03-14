import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  NostrDart.configure();
  group('Event Message', () {
    const String privateKey = 'ab67ae56758c77096a65e7f2ff41aaf8fcddd0817da971895885848fadf6eef9';
    const String publicKey = '9e65c9a8a30778440065603a58aa5ab07d14ffd870a14c6c76b63cdea96b8ba0';
    const String subscriptionId = '3497816659629849';
    const String content = 'Message Content';
    const int createdAt = 1676148923;
    const String eventId = 'fa19bd8aec0b5c08b6e6c78b68b3530134abb3f9b751a3e3696c80e3020da39a';
    const String sig =
        '84c8616f10d840a18c2c6f246154d34296c029cfd2a5bcc68d996b70fd4989ad433cec27262aa97fb30191760bd61a6e1d495361ac52475a384e943e2afadf6e';
    const int kind = 1;
    const String tagE = '656edc6216203b1a91f129e4166bedb1b7c856825152d6709e74c46eb94d047b';
    const String tagP = '84dee6e676e5bb67b4ad4e042cf70cbd8681155db535942fcc6a0533858a7240';
    const String tags = '[["e","$tagE"],["p","$tagP"]]';
    const payload =
        '{"id":"$eventId","pubkey":"$publicKey","created_at":$createdAt,"kind":$kind,"tags":$tags,"content":"$content","sig":"$sig"}';
    const String rawEvent = '["EVENT","$subscriptionId",$payload]';

    test('might be instantiated with unnamed constructor', () {
      final EventMessage message = EventMessage(
        id: eventId,
        pubkey: publicKey,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
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
        equals(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)),
      );
    });

    test('might be instantiated with fromData constructor', () async {
      final KeyStore keyStore = KeyStore.fromPrivate(privateKey);
      final EventMessage message = await EventMessage.fromData(
        signer: keyStore,
        kind: kind,
        content: content,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt * 1000),
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
        equals(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000)),
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

    test('might be stringified to a raw message with toString method', () {
      final EventMessage message = EventMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>);
      expect(message.toString(), equals(rawEvent));
    });

    test('validate() should return true for a valid event', () async {
      final eventValid =
          await EventMessage.fromJson(jsonDecode(rawEvent) as List<dynamic>).validate();
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
