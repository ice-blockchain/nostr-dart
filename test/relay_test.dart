import 'dart:async';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() async {
  group('Relay', () {
    NostrDart.configure();

    test('must support subscribing', () async {
      final NostrRelay relay =
          await NostrRelay.connect('wss://bom1-1.testnet.ion-connect.ice.vip:4443');

      final RequestMessage requestMessage = RequestMessage()
        ..addFilter(const RequestFilter(kinds: [1], limit: 1))
        ..addFilter(
          RequestFilter(kinds: const [0], limit: 1, since: DateTime(2020)),
        );

      final NostrSubscription subscription = relay.subscribe(requestMessage);

      final Completer<ClosedMessage> completer = Completer();
      final StreamSubscription listener = subscription.messages.listen((event) {
        if (event is ClosedMessage) {
          completer.complete(event);
        }
      });
      final ClosedMessage closedMessage = await completer.future;

      relay.unsubscribe(subscription.id);
      listener.cancel();

      expect(closedMessage.subscriptionId, equals(subscription.id));
    });
  });
}
