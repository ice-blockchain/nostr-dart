import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/logging.dart';

/// A class to represent a Nostr relay.
///
/// Relays are like the backend servers for Nostr.
/// They allow Nostr clients to send them messages, and they may (or may not)
/// store those messages and broadcast those messages to all other connected clients.
class NostrRelay {
  /// Closes the connection if the user forgets to
  static final Finalizer<WebSocket> _finalizer =
      Finalizer((socket) => socket.close());

  /// URL of the Relay's WebSocket.
  ///
  /// Must use the scheme `ws` or `wss`.
  final String url;

  /// Corresponding Relay's WebSocket connection
  final WebSocket socket;

  /// Stream of decoded WebSocket's messages
  late Stream<RelayMessage> messages;

  /// Active Relay's [NostrSubscription]s
  final Map<String, NostrSubscription> _subscriptions = {};

  NostrRelay({
    required this.url,
    required this.socket,
  }) {
    final controller = StreamController<RelayMessage>.broadcast();
    controller
        .addStream(socket.messages.transform(_messageTransformer))
        .whenComplete(controller.close);
    messages = controller.stream;
    socket.connection.listen(_onConnectionStateChange);
    messages.listen(_onIncomingMessage);
    _finalizer.attach(this, socket, detach: this);
  }

  /// Closes the corresponding socket connection.
  void close() {
    socket.close();
    _finalizer.detach(this);
  }

  /// Sends the [EventMessage] to the Relay and waits for
  /// an [OkMessage] with the same eventId.
  Future<OkMessage> sendEvent(EventMessage event) async {
    try {
      sendMessage(event);
      return messages
          .where((message) => message is OkMessage)
          .cast<OkMessage>()
          .firstWhere((message) => message.eventId == event.id);
    } catch (error, stack) {
      logWarning("$url Failed to send event $event", error, stack);
      rethrow;
    }
  }

  /// Sends the [RelayMessage] to the Relay
  void sendMessage(RelayMessage message) {
    if (socket.connection is Connecting ||
        socket.connection is Reconnecting ||
        socket.connection is Disconnected) {
      throw SocketException('Connection to $url is not established');
    }
    socket.send(message.toString());
    logInfo(() => '↑ $url $message');
  }

  /// Sends the provided [RequestMessage] to the Relay and
  /// returns an instance of [NostrSubscription] that contains
  /// a stream of [RelayMessage] filtered by the [requestMessage]'s [subscriptionId]
  NostrSubscription subscribe(RequestMessage requestMessage) {
    try {
      sendMessage(requestMessage);
      final NostrSubscription subscription =
          NostrSubscription(requestMessage, messages);
      _subscriptions[subscription.id] = subscription;
      return subscription;
    } catch (error, stack) {
      logWarning("Failed to subscribe to relay $url", error, stack);
      rethrow;
    }
  }

  /// Closes the previously created [NostrSubscription] identified by the provided [subscriptionId].
  void unsubscribe(String subscriptionId) {
    try {
      final NostrSubscription? subscription = _subscriptions[subscriptionId];
      if (subscription == null) {
        throw SubscriptionNotFoundException(subscriptionId);
      }
      sendMessage(CloseMessage(subscriptionId: subscriptionId));
      subscription.dispose();
      _subscriptions.remove(subscriptionId);
    } catch (error, stack) {
      logWarning("Failed to unsubscribe from relay $url", error, stack);
      rethrow;
    }
  }

  void _onConnectionStateChange(ConnectionState state) {
    logInfo(() => '$url connection state is ${state.runtimeType}');
    if (state is Reconnected) {
      _renewSubscriptions();
    }
  }

  void _onIncomingMessage(RelayMessage message) {
    logInfo(() => '↓ $url $message');
  }

  void _renewSubscriptions() {
    for (final NostrSubscription subscription in _subscriptions.values) {
      sendMessage(subscription.getRenewRequestMessage());
    }
  }

  /// Creates a new Relay and waits for it to be connected.
  static Future<NostrRelay> connect(
    String url, [
    WebSocket? customSocket,
  ]) async {
    final WebSocket socket = customSocket ?? WebSocket(Uri.parse(url));
    final relay = NostrRelay(url: url, socket: socket);
    await socket.connection.firstWhere((state) => state is Connected);
    return relay;
  }
}

StreamTransformer<dynamic, RelayMessage> _messageTransformer =
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
      logWarning(() => 'Stream transform error', error, stack);
      sink.addError(error);
    }
  },
);
