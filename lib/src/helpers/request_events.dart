import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';

/// Requests stored [RelayMessage]s from the provided [NostrRelay] using [RequestMessage].
///
/// Stored events are those controlled by the `limit` property of a filter
/// and are returned before the [EoseMessage].
///
/// Upon receiving the stored events, the subscription is closed. If you
/// need to keep the subscription to receive real-time [RelayMessage]s, consider
/// using [collectStoredEvents] instead.
Stream<RelayMessage> requestEvents(
  RequestMessage requestMessage,
  NostrRelay relay, {
  bool keepSubscription = false,
}) async* {
  final NostrSubscription subscription = relay.subscribe(requestMessage);

  await for (final message in subscription.messages) {
    yield message;
    if (message is EoseMessage || message is ClosedMessage || message is NoticeMessage) {
      if (!keepSubscription) {
        relay.unsubscribe(subscription.id, sendCloseMessage: message is EoseMessage);
      }
    }
  }
}
