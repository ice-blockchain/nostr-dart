import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() async {
  group('Relay', () {
    NostrDart.configure(logLevel: NostrLogLevel.ALL);

    test('must support subscribing', () async {
      final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

      final RequestMessage requestMessage = RequestMessage()
        ..addFilter(const RequestFilter(kinds: [1], limit: 1))
        ..addFilter(
          RequestFilter(kinds: const [0], limit: 1, since: DateTime(2020)),
        );

      final NostrSubscription subscription = relay.subscribe(requestMessage);

      final Completer<EoseMessage> completer = Completer();
      final List<EventMessage> events = [];
      final StreamSubscription listener = subscription.messages.listen((event) {
        if (event is EoseMessage) {
          completer.complete(event);
        } else if (event is EventMessage) {
          events.add(event);
        }
      });
      final EoseMessage eoseMessage = await completer.future;

      relay.unsubscribe(subscription.id);
      listener.cancel();

      expect(eoseMessage.subscriptionId, equals(subscription.id));
      expect(events.length, equals(2));
    });
  });
}
