import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';

/// Requests stored [EventMessage]s from the provided [NostrRelay] using [RequestMessage].
///
/// Stored events are those controlled by the `limit` property of a filter
/// and are returned before the [EoseMessage].
///
/// Upon receiving the stored events, the subscription is closed. If you
/// need to keep the subscription to receive real-time [EventMessage]s, consider
/// using [collectStoredEvents] instead.
Future<List<EventMessage>> requestEvents(
  RequestMessage requestMessage,
  NostrRelay relay,
) async {
  final NostrSubscription subscription = relay.subscribe(requestMessage);

  final events = await collectStoredEvents(subscription);

  relay.unsubscribe(subscription.id);

  return events;
}
