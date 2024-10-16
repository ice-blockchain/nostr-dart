import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/model/closed_message.dart';

/// Requests stored [EventMessage]s from the provided [NostrRelay] using [RequestMessage].
///
/// Stored events are those controlled by the `limit` property of a filter
/// and are returned before the [EoseMessage].
///
/// Upon receiving the stored events, the subscription is closed. If you
/// need to keep the subscription to receive real-time [EventMessage]s, consider
/// using [collectStoredEvents] instead.
Stream<EventMessage> requestEvents(
  RequestMessage requestMessage,
  NostrRelay relay,
) async* {
  final NostrSubscription subscription = relay.subscribe(requestMessage);

  await for (final message in subscription.messages) {
    if (message is EventMessage) {
      yield message;
    } else if (message is EoseMessage || message is ClosedMessage) {
      relay.unsubscribe(subscription.id);
    }
  }
}
