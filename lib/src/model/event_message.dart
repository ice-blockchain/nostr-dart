import 'dart:async';
import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/crypto/utils.dart';

/// Representation of a Nostr `EVENT` Message
///
/// Used to publish events to relays AND receive events requested by clients.
///
/// JSON representation on relay to client communication is `["EVENT", <subscription_id>, <event JSON>]`
///
/// On client to relay communication `["EVENT", <event JSON>]`
///
/// Usage example for client to relay communication:
/// ```
/// final KeyStore keyStore = KeyStore.generate();
/// final EventMessage event = EventMessage.fromData(
///   signer: keyStore,
///   kind: 0,
///   content: '{"name":"test"}',
/// );
/// final OkMessage result = await relay.sendEvent(event);
/// ```
///
/// Usage example for relay to client communication:
/// ```
/// final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');
///
/// final RequestMessage requestMessage = RequestMessage()
///     ..addFilter(const RequestFilter(kinds: [1], limit: 5));
///
/// final NostrSubscription subscription = relay.subscribe(requestMessage);
///
/// final StreamSubscription listener = subscription.messages.listen((event) {
///   if (event is EventMessage) {
///     // Do something with the event
///   }
/// });
///
/// relay.unsubscribe(subscription.id);
/// listener.cancel();
/// ```
class EventMessage extends RelayMessage {
  static const String type = 'EVENT';

  /// 32-bytes lowercase hex-encoded `sha256` of the serialized event data.
  ///
  /// See [calculateEventId] for more.
  final String id;

  /// 32-bytes lowercase hex-encoded public key of the event creator.
  final String pubkey;

  /// Time when the event is created.
  final DateTime createdAt;

  /// Integer between 0 and 65535.
  ///
  /// Kinds specify how clients should interpret the meaning of each event
  /// and the other fields of each event (e.g. an "r" tag may have a meaning
  /// in an event of kind 1 and an entirely different meaning in an event of kind 10002).
  /// Each NIP may define the meaning of a set of kinds that weren't defined elsewhere.
  ///
  /// [See more](https://github.com/nostr-protocol/nips/blob/master/01.md#kinds)
  final int kind;

  /// Each tag is an array of strings of arbitrary size, with some conventions around them.
  ///
  /// The first element of the tag array is referred to as the tag name or key and the second as the tag value.
  ///
  /// [See more](https://github.com/nostr-protocol/nips/blob/master/01.md#tags)
  final List<List<String>> tags;

  /// Arbitrary string.
  ///
  /// May be plain text OR encoded JSON depending on [kind].
  final String? content;

  /// 64-bytes lowercase hex of the signature of the sha256 hash of the serialized event data,
  /// which is the same as the [id] field.
  final String? sig;

  /// An arbitrary, non-empty string of max length 64 chars, that should be used to represent a subscription.
  ///
  /// It exists only in events that are sent from relay to client.
  final String? subscriptionId;

  EventMessage({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.tags,
    required this.sig,
    this.content,
    this.subscriptionId,
  });

  static FutureOr<EventMessage> fromData({
    required EventSigner signer,
    required int kind,
    String? content,
    List<List<String>> tags = const [],
    DateTime? createdAt,
  }) async {
    createdAt ??= DateTime.now();
    final normalizedTags = _normalizeTags(tags);

    final String eventId = calculateEventId(
      publicKey: signer.publicKey,
      createdAt: createdAt,
      kind: kind,
      tags: normalizedTags,
      content: content,
    );

    return EventMessage(
      id: eventId,
      pubkey: signer.publicKey,
      createdAt: createdAt,
      kind: kind,
      tags: normalizedTags,
      content: content,
      sig: await signer.sign(message: eventId),
    );
  }

  factory EventMessage.fromJson(List json) {
    final String type = json.first as String;
    final Map<String, dynamic> payload = json.last as Map<String, dynamic>;

    if (type != EventMessage.type) {
      throw ArgumentError('json', 'Must be of type "${EventMessage.type}"');
    }

    return EventMessage.fromPayloadJson(
      payload,
      subscriptionId: json.length == 3 ? json[1] as String : null,
    );
  }

  factory EventMessage.fromPayloadJson(Map<String, dynamic> payloadJson, {String? subscriptionId}) {
    return EventMessage(
      id: payloadJson['id'] as String,
      pubkey: payloadJson['pubkey'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (payloadJson['created_at'] as int) * 1000,
      ),
      kind: payloadJson['kind'] as int,
      tags: (payloadJson['tags'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList(),
      content: payloadJson['content'] as String?,
      sig: payloadJson['sig'] as String?,
      subscriptionId: subscriptionId,
    );
  }

  @override
  List toJson() {
    final Map<String, dynamic> payload = {
      'id': id,
      'pubkey': pubkey,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'kind': kind,
      'tags': tags,
      if (content != null) 'content': content,
      'sig': sig,
    };
    if (subscriptionId != null) {
      return [EventMessage.type, subscriptionId, payload];
    } else {
      return [EventMessage.type, payload];
    }
  }

  Future<bool> validate() async {
    final String calculatedId = calculateEventId(
      publicKey: pubkey,
      createdAt: createdAt,
      kind: kind,
      tags: tags,
      content: content,
    );

    if (id != calculatedId || sig == null) {
      return false;
    }

    return await NostrDart.signatureVerifier.verify(
      signature: sig!,
      message: id,
      publicKey: pubkey,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pubkey,
        createdAt.millisecondsSinceEpoch ~/ 1000,
        tags,
        content,
        sig,
        subscriptionId,
      ];

  /// Normalizes tags by removing trailing empty strings from each tag
  ///
  /// A normalized tag is added to the result if:
  /// 1. It contains more than one element after normalization, OR
  /// 2. The original tag had exactly one element
  ///
  /// Example:
  /// ```
  /// Input: [["e", "id", "", ""], ["empty", "", ""], ["e", "id", "", "pubkey"], ["single"]]
  /// Output: [["e", "id"], ["e", "id", "", "pubkey"], ["single"]]
  /// ```
  static List<List<String>> _normalizeTags(List<List<String>> tags) {
    final normalizedTags = <List<String>>[];

    for (final tagList in tags) {
      final normalizedTagList = [...tagList];

      while (normalizedTagList.isNotEmpty && normalizedTagList.last.isEmpty) {
        normalizedTagList.removeLast();
      }

      if (normalizedTagList.length > 1 || tagList.length == 1) {
        normalizedTags.add(normalizedTagList);
      }
    }

    return normalizedTags;
  }

  /// Calculate event id using a given event data.
  ///
  /// To calculate the [id], we `sha256` the serialized event.
  /// The serialization is done over the UTF-8 JSON-serialized string
  /// (with no white space or line breaks) of the following structure:
  /// ```
  /// [
  ///   0,
  ///   <[pubkey], as a lowercase hex string>,
  ///   <[createdAt], as unix timestamp in seconds>,
  ///   <[kind], as a number>,
  ///   <[tags], as an array of arrays of non-null strings>,
  ///   <[content], as a string>
  /// ]
  /// ```
  static String calculateEventId({
    required String publicKey,
    required DateTime createdAt,
    required int kind,
    required List<List<String>> tags,
    String? content,
  }) {
    return sha256(
      jsonEncode([
        0,
        publicKey,
        createdAt.millisecondsSinceEpoch ~/ 1000,
        kind,
        tags,
        content ?? '',
      ]),
    );
  }
}
