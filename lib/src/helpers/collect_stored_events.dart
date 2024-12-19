import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';

/// Collects stored [EventMessage]s from the provided [NostrSubscription].
///
/// Stored events are those controlled by the `limit` property of a filter
/// and are returned before the [EoseMessage].
///
/// Useful when keeping the subscription alive for further events is necessary.
/// Otherwise [requestEvents] might be used.
Future<List<EventMessage>> collectStoredEvents(
  NostrSubscription subscription,
) async {
  final Completer<EoseMessage> completer = Completer();
  final List<EventMessage> events = [];

  final StreamSubscription messageListener = subscription.messages.listen(
    (event) {
      if (event is EventMessage) {
        events.add(event);
      } else if (event is EoseMessage) {
        completer.complete(event);
      } else if (event is ClosedMessage) {
        completer.completeError(event.message);
      }
    },
  );

  await completer.future;

  messageListener.cancel();

  return events;
}
