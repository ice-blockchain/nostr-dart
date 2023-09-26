import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nostr_dart/src/exceptions/subscription_not_found.dart';
import 'package:nostr_dart/src/logging.dart';
import 'package:nostr_dart/src/model/close_message.dart';
import 'package:nostr_dart/src/model/eose_message.dart';
import 'package:nostr_dart/src/model/event_message.dart';
import 'package:nostr_dart/src/model/notice_message.dart';
import 'package:nostr_dart/src/model/ok_message.dart';
import 'package:nostr_dart/src/model/relay_message.dart';
import 'package:nostr_dart/src/model/request_message.dart';
import 'package:nostr_dart/src/subscription.dart';

/// A class to represent a Nostr relay.
///
/// Relays are like the backend servers for Nostr.
/// They allow Nostr clients to send them messages, and they may (or may not)
/// store those messages and broadcast those messages to all other connected clients.
class NostrRelay {
  /// Closes the connection if the user forgets to, using [Finalizer](https://api.flutter.dev/flutter/dart-core/Finalizer-class.html)
  static final Finalizer<WebSocket> _finalizer = Finalizer((socket) {
    socket.close();
  });

  /// URL of the Relay's WebSocket.
  ///
  /// Must use the scheme `ws` or `wss`.
  final String url;

  /// Corresponding Relay's WebSocket connection
  final WebSocket socket;

  /// Stream of decoded WebSocket's messages
  final Stream<RelayMessage> messages;

  /// Active Relay's subscriptions
  final Map<String, NostrSubscription> subscriptions = {};

  NostrRelay._({
    required this.url,
    required this.messages,
    required this.socket,
  });

  /// Close the corresponding socket connection
  void close() {
    socket.close();
    _finalizer.detach(this);
  }

  /// Send an [EventMessage] to the Relay and wait for
  /// the corresponding [OkMessage] in response.
  Future<OkMessage> sendEvent(EventMessage event) async {
    socket.add(event.toString());
    return messages
        .where((message) => message is OkMessage)
        .cast<OkMessage>()
        .firstWhere((message) => message.eventId == event.id);
  }

  /// Sends the provided [RequestMessage] to the Relay and
  /// returns an instance of [NostrSubscription] that contains
  /// a stream of [RelayMessage] filtered by the [requestMessage]'s [subscriptionId]
  NostrSubscription subscribe(RequestMessage requestMessage) {
    final NostrSubscription subscription =
        NostrSubscription(requestMessage, messages);
    subscriptions[subscription.id] = subscription;
    socket.add(requestMessage.toString());
    return subscription;
  }

  /// Closes the previously created [NostrSubscription] identified by the provided [subscriptionId].
  void unsubscribe(String subscriptionId) {
    try {
      final NostrSubscription? subscription = subscriptions[subscriptionId];
      if (subscription == null) {
        throw SubscriptionNotFoundException(subscriptionId);
      }
      socket.add(CloseMessage(subscriptionId: subscriptionId).toString());
      subscription.dispose();
      subscriptions.remove(subscriptionId);
    } catch (error, stack) {
      logWarningWithError(
        () => ("Unable to unsubscribe from relay $url", error, stack),
      );
      rethrow;
    }
  }

  /// Creates a new Relay with the provided url.
  ///
  /// Method creates a new WebSocket connection to the given url and
  /// creates a stream of [RelayMessage]s using [_messagesTransformer]
  static Future<NostrRelay> connect(String url) async {
    final WebSocket socket = await WebSocket.connect(url);
    final Stream<RelayMessage> messages =
        socket.asBroadcastStream().transform(_messagesTransformer);
    final NostrRelay relay =
        NostrRelay._(url: url, messages: messages, socket: socket);
    _finalizer.attach(relay, socket, detach: relay);
    return relay;
  }
}

StreamTransformer<dynamic, RelayMessage> _messagesTransformer =
    StreamTransformer.fromHandlers(
  handleData: (message, sink) {
    try {
      final jsonMessage = jsonDecode(message as String) as List<dynamic>;
      switch (jsonMessage[0]) {
        case EventMessage.type:
          sink.add(EventMessage.fromJson(jsonMessage));
        case EoseMessage.type:
          sink.add(EoseMessage.fromJson(jsonMessage));
        case OkMessage.type:
          sink.add(OkMessage.fromJson(jsonMessage));
        case NoticeMessage.type:
          sink.add(NoticeMessage.fromJson(jsonMessage));
        default:
          logWarning(() => 'Unknown message $message');
      }
    } catch (error, stack) {
      logWarningWithError(() => ('Stream transform error', error, stack));
      sink.addError(error);
    }
  },
);
