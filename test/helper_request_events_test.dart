import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('requestEvents helper', () {
    NostrDart.configure(logLevel: NostrLogLevel.ALL);

    test('should fetch events', () async {
      final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

      final RequestMessage requestMessage = RequestMessage()
        ..addFilter(const RequestFilter(kinds: [1], limit: 2));

      final events = await requestEvents(requestMessage, relay);

      expect(events.length, equals(2));
    });
  });
}
