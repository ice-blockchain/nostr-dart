// ignore_for_file: avoid_print

import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';

void main() async {
  setNostrLogLevel(NostrLogLevel.ALL);

  final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

  final RequestMessage requestMessage = RequestMessage()
    ..addFilter(const RequestFilter(kinds: [1], limit: 5))
    ..addFilter(
      RequestFilter(kinds: const [0], limit: 1, since: DateTime(2020)),
    );

  final NostrSubscription subscription = relay.subscribe(requestMessage);

  final StreamSubscription listener = subscription.messages.listen((event) {
    if (event is EoseMessage) {
      print('Stored events are received');
    }
  });

  await Future.delayed(const Duration(seconds: 2));

  relay.unsubscribe(subscription.id);
  listener.cancel();

  final KeyStore keyStore = KeyStore.generate();

  final EventMessage event = EventMessage.fromData(
    keyStore: keyStore,
    kind: 0,
    content: '{"name":"test"}',
  );

  final OkMessage result = await relay.sendEvent(event);

  print("Event is accepted - ${result.accepted} $result");
}
