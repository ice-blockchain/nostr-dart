import 'dart:async';

import 'package:nostr_dart/src/model/eose_message.dart';
import 'package:nostr_dart/src/model/event_message.dart';
import 'package:nostr_dart/src/model/relay_message.dart';
import 'package:nostr_dart/src/model/request_message.dart';

/// A class to represent a Nostr subscription.
///
/// The class in not intended to be instantiated manually.
/// To start a subscription, use [NostrRelay.subscribe]:
/// ```
/// final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');
/// final RequestMessage requestMessage =
///   RequestMessage().addFilter(const RequestFilter(kinds: [1], limit: 5));
/// final NostrSubscription subscription = relay.subscribe(requestMessage);
/// ```
///
/// To cancel subscription, use [NostrRelay.unsubscribe]:
/// ```
/// relay.unsubscribe(subscription.id);
/// ```
class NostrSubscription {
  /// Arbitrary, non-empty string of max length 64 chars that represents a subscription.
  late String id;

  /// A [RequestMessage] that is used to start the subscription.
  late RequestMessage requestMessage;

  /// A stream of [RelayMessage]s that are filtered by the subscription's id.
  late Stream<RelayMessage> messages;

  /// The last received subscription's [EventMessage] created time.
  DateTime? _lastEventCreatedTime;

  /// [messages]'s subscription to track [_lastEventCreatedTime]
  late StreamSubscription<RelayMessage> _lastEventCreatedTimeSubscription;

  NostrSubscription(
    this.requestMessage,
    Stream<RelayMessage> relayMessages,
  ) {
    id = requestMessage.subscriptionId;
    messages = relayMessages.where(_isSubscriptionMessage);
    _lastEventCreatedTimeSubscription =
        messages.listen(_trackLastEventCreatedTime);
  }

  DateTime? get lastMessageTime => _lastEventCreatedTime;

  /// Clean-up method called on subscription cancellation.
  ///
  /// [dispose] is used to remove subscriptions / release memory
  /// See [NostrRelay.unsubscribe]
  void dispose() {
    _lastEventCreatedTimeSubscription.cancel();
  }

  bool _isSubscriptionMessage(RelayMessage message) {
    return (message is EventMessage &&
            message.subscriptionId == requestMessage.subscriptionId) ||
        (message is EoseMessage &&
            message.subscriptionId == requestMessage.subscriptionId);
  }

  void _trackLastEventCreatedTime(RelayMessage event) {
    if (event is EventMessage) {
      _lastEventCreatedTime = event.createdAt;
    }
  }
}
