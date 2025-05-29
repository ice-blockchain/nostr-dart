import 'dart:async';
import 'dart:collection';

import 'package:nostr_dart/nostr_dart.dart';

/// A class to represent a Nostr subscription.
///
/// The class in not intended to be instantiated manually.
/// To start a subscription, use [NostrRelay.subscribe]:
/// ```
/// final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');
/// final RequestMessage requestMessage = RequestMessage()
///      ..addFilter(const RequestFilter(kinds: [1], limit: 5))
/// final NostrSubscription subscription = relay.subscribe(requestMessage);
/// ```
///
/// To cancel subscription, use [NostrRelay.unsubscribe]:
/// ```
/// relay.unsubscribe(subscription.id);
/// ```
class NostrSubscription {
  /// The max number of the last [EventMessage]s, remembered to detect duplicates.
  ///
  /// See [_isUniqMessage] for details.
  static const _lastEventIdsLength = 20;

  /// Arbitrary, non-empty string of max length 64 chars that represents the subscription.
  late String id;

  /// A [RequestMessage] that is used to start the subscription.
  late RequestMessage requestMessage;

  /// A StreamController to filter the incoming [RelayMessage]s
  /// according to the Subscription's logic.
  final StreamController<RelayMessage> _messagesController = StreamController.broadcast();

  /// A stream of uniq [RelayMessage]s of the current Subscription.
  late Stream<RelayMessage> messages;

  /// Created timestamp of the last [EventMessage] received by the subscription.
  int? _lastEventCreatedTime;

  /// Method to generate a [RequestMessage] to renew the subscription.
  ///
  /// [NostrRelay]'s connection may be aborted due to variety of reasons -
  /// no internet connection on the user's device, device lock screen is triggered,
  /// OS takes away the resources due to staying in the background and many more.
  /// In those cases [NostrRelay] tries to reconnect as soon as possible. And
  /// since each reconnection is a new WebSocket connection, previous nostr
  /// subscriptions should also be renewed.
  /// But to renew a subscription the initial [RequestMessage] is not suitable for
  /// most cases, hence we're using [getRenewRequestMessage] method to generate a new one.
  ///
  /// The default implementation for this function is defined in [_defaultGetRenewRequestMessage].
  late RequestMessage Function() getRenewRequestMessage;

  /// Keep track of stream subscriptions to be able to cancel those when needed.
  final List<StreamSubscription> _streamSubscriptions = [];

  /// Uniq ids of the last [EventMessage]s.
  ///
  /// The queue is used to detect duplicate events.
  final ListQueue<String> _lastEventIds = ListQueue();

  NostrSubscription(
    this.requestMessage,
    Stream<RelayMessage> relayMessages,
  ) {
    _streamSubscriptions.add(
      relayMessages.listen(
        (message) {
          if (_isSubscriptionMessage(message) && _isUniqMessage(message)) {
            _messagesController.sink.add(message);
          }
        },
        onDone: _messagesController.close,
      ),
    );
    messages = _messagesController.stream;
    id = requestMessage.subscriptionId;
    getRenewRequestMessage = _defaultGetRenewRequestMessage;
    _streamSubscriptions.add(messages.listen(_trackLastEventCreatedTime));
  }

  int? get lastMessageTime => _lastEventCreatedTime;

  /// Clean-up method called on subscription cancellation.
  ///
  /// [dispose] is used to remove subscriptions / release memory
  /// See [NostrRelay.unsubscribe]
  void dispose() {
    for (final StreamSubscription subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _messagesController.close();
  }

  /// Default implementation for generating a [RequestMessage] to renew the subscription.
  ///
  /// Initial [RequestMessage]'s filters but with:
  /// `since` set to [_lastEventCreatedTime].
  /// `limit` is removed.
  ///
  /// This way we request all the events that match the initial filters and happened
  /// after the last received [EventMessage].
  RequestMessage _defaultGetRenewRequestMessage() {
    final RequestMessage requestMessage =
        RequestMessage(subscriptionId: this.requestMessage.subscriptionId);
    for (final RequestFilter filter in this.requestMessage.filters) {
      requestMessage.addFilter(
        filter.copyWith(
          since: _lastEventCreatedTime != null ? () => _lastEventCreatedTime : null,
          limit: () => null,
        ),
      );
    }
    return requestMessage;
  }

  bool _isSubscriptionMessage(RelayMessage message) {
    return (message is EventMessage && message.subscriptionId == requestMessage.subscriptionId) ||
        (message is EoseMessage && message.subscriptionId == requestMessage.subscriptionId) ||
        (message is ClosedMessage && message.subscriptionId == requestMessage.subscriptionId);
  }

  /// In some cases there might be that the same [EventMessage] comes several times.
  ///
  /// E.g. after the socket reconnection.
  bool _isUniqMessage(RelayMessage message) {
    if (message is! EventMessage) {
      return true;
    }
    if (_lastEventIds.contains(message.id)) {
      return false;
    }
    _lastEventIds.addFirst(message.id);
    if (_lastEventIds.length > _lastEventIdsLength) {
      _lastEventIds.removeLast();
    }
    return true;
  }

  void _trackLastEventCreatedTime(RelayMessage event) {
    if (event is EventMessage) {
      _lastEventCreatedTime = event.createdAt;
    }
  }
}
