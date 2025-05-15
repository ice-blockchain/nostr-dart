import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/model/grouped_events_message.dart';

/// A class to represent a Nostr relay.
///
/// Relays are like the backend servers for Nostr.
/// They allow Nostr clients to send them messages, and they may (or may not)
/// store those messages and broadcast those messages to all other connected clients.
class NostrRelay {
  /// Closes the connection if the user forgets to
  static final Finalizer<WebSocket> _finalizer = Finalizer((socket) => socket.close());

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

  /// Active Relay's [NostrSubscription]s count stream controller
  final StreamController<int> _subscriptionsCountController = StreamController<int>.broadcast();

  /// Stream controller to notify listeners when the relay is closed.
  final StreamController<String> _closeNotificationController =
      StreamController<String>.broadcast();

  /// Stream to notify listeners when the relay is closed.
  Stream<String> get onClose => _closeNotificationController.stream;

  /// Logger instance
  NostrDartLogger? get _logger => NostrDart.logger;

  NostrRelay({
    required this.url,
    required this.socket,
  }) {
    final controller = StreamController<RelayMessage>.broadcast();
    controller.addStream(_transformMessages(socket.messages)).whenComplete(controller.close);
    messages = controller.stream;
    socket.connection.listen(_onConnectionStateChange);
    messages.listen(_onIncomingMessage);
    _finalizer.attach(this, socket, detach: this);
  }

  /// Active Relay's [NostrSubscription]s count stream
  Stream<int> get subscriptionsCountStream => _subscriptionsCountController.stream;

  /// Closes the corresponding socket connection.
  void close() {
    socket.close();
    _subscriptionsCountController.close();
    _closeNotificationController.add(url);
    _closeNotificationController.close();
    _finalizer.detach(this);
  }

  /// Convenient method to send one [EventMessage] to the Relay.
  ///
  /// For details check [sendEvents] method.
  Future<void> sendEvent(EventMessage event) async {
    return sendEvents([event]);
  }

  /// Sends the [EventMessage]s to the Relay.
  ///
  /// It checks for corresponding `OkMessage` responses to ensure
  /// that all events were accepted. If any events are not accepted,
  /// it throws a [SendEventException] with the message from the first
  /// non-accepted event.
  Future<void> sendEvents(List<EventMessage> events) async {
    try {
      final eventIds = events.map((event) => event.id).toList();
      final eventsMessage = GroupedEventsMessage(events: events);
      sendMessage(eventsMessage);
      final okMessages = await messages
          .where((message) => message is OkMessage)
          .cast<OkMessage>()
          .where((message) => eventIds.contains(message.eventId))
          .take(events.length)
          .toList();

      if (okMessages.isEmpty) {
        throw SendEventException('No OkMessage received for event $eventIds');
      }

      final notAccepted = okMessages.where((message) => !message.accepted);
      if (notAccepted.isNotEmpty) {
        throw SendEventException(notAccepted.first.message);
      }
    } catch (error, stack) {
      _logger?.warning("$url Failed to send events $events", error, stack);
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
    _logger?.info('↑ $url $message');
  }

  /// Sends the provided [RequestMessage] to the Relay and
  /// returns an instance of [NostrSubscription] that contains
  /// a stream of [RelayMessage] filtered by the [requestMessage]'s [subscriptionId]
  NostrSubscription subscribe(RequestMessage requestMessage) {
    try {
      sendMessage(requestMessage);
      final NostrSubscription subscription = NostrSubscription(requestMessage, messages);
      _subscriptions[subscription.id] = subscription;
      _subscriptionsCountController.add(_subscriptions.keys.length);
      return subscription;
    } catch (error, stack) {
      _logger?.warning("Failed to subscribe to relay $url", error, stack);
      rethrow;
    }
  }

  /// Closes the previously created [NostrSubscription] identified by the provided [subscriptionId].
  void unsubscribe(String subscriptionId, {bool sendCloseMessage = true}) {
    try {
      final NostrSubscription? subscription = _subscriptions[subscriptionId];
      if (subscription == null) {
        throw SubscriptionNotFoundException(subscriptionId);
      }
      if (sendCloseMessage) sendMessage(CloseMessage(subscriptionId: subscriptionId));
      subscription.dispose();
      _subscriptions.remove(subscriptionId);
      _subscriptionsCountController.add(_subscriptions.keys.length);
    } catch (error, stack) {
      _logger?.warning("Failed to unsubscribe from relay $url", error, stack);
      rethrow;
    }
  }

  void _onConnectionStateChange(ConnectionState state) {
    _logger?.info('$url connection state is ${state.runtimeType}');
    if (state is Reconnected) {
      _renewSubscriptions();
    }
  }

  void _onIncomingMessage(RelayMessage message) {
    _logger?.info('↓ $url $message');
  }

  void _renewSubscriptions() {
    for (final NostrSubscription subscription in _subscriptions.values) {
      sendMessage(subscription.getRenewRequestMessage());
    }
  }

  Stream<RelayMessage> _transformMessages(Stream<dynamic> messages) {
    return messages
        .asyncMap<RelayMessage?>((message) async {
          try {
            final jsonMessage = jsonDecode(message as String) as List<dynamic>;
            switch (jsonMessage[0]) {
              case EventMessage.type:
                final eventMessage = EventMessage.fromJson(jsonMessage);
                if (await eventMessage.validate()) {
                  return eventMessage;
                } else {
                  _logger?.warning('Invalid event $message');
                  return null;
                }
              case EoseMessage.type:
                return EoseMessage.fromJson(jsonMessage);
              case OkMessage.type:
                return OkMessage.fromJson(jsonMessage);
              case NoticeMessage.type:
                return NoticeMessage.fromJson(jsonMessage);
              case AuthMessage.type:
                return AuthMessage.fromJson(jsonMessage);
              case ClosedMessage.type:
                return ClosedMessage.fromJson(jsonMessage);
              default:
                _logger?.warning('Unknown message $message');
                return null;
            }
          } catch (error, stack) {
            _logger?.warning('Stream transform error', error, stack);
            return null;
          }
        })
        .where((event) => event != null)
        .cast<RelayMessage>();
  }

  /// Creates a new Relay and waits for it to be connected.
  static Future<NostrRelay> connect(
    String url, [
    WebSocket? customSocket,
  ]) async {
    final WebSocket socket = customSocket ?? WebSocket(Uri.parse(url));
    final relay = NostrRelay(url: url, socket: socket);
    await socket.connection.firstWhere((state) => state is Connected || state is Reconnected);
    return relay;
  }
}
