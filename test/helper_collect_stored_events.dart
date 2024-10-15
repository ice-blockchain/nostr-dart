import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('collectInitialEvents helper', () {
    NostrDart.configure(logLevel: NostrLogLevel.ALL);

    test('should collect initial events', () async {
      final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

      final RequestMessage requestMessage = RequestMessage()
        ..addFilter(const RequestFilter(kinds: [1], limit: 2));

      final NostrSubscription subscription = relay.subscribe(requestMessage);

      final events = await collectStoredEvents(subscription);

      relay.unsubscribe(subscription.id);

      expect(events.length, equals(2));
    });
  });
}
