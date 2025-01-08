import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('requestEvents helper', () {
    NostrDart.configure();

    test('should fetch events', () async {
      final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

      final RequestMessage requestMessage = RequestMessage()
        ..addFilter(const RequestFilter(kinds: [1], limit: 2));

      final events = [];
      final stream = requestEvents(requestMessage, relay);
      await for (final event in stream) {
        events.add(event);
      }

      expect(events.length, equals(3));
    });
  });
}
