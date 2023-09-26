import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Request Message', () {
    const subscriptionId =
        '117fadd81bf05e00a3b32ceb4ca69c3666ec15319c315360c04fdc3fbbd86b2c';
    const rawMessage = '["REQ","$subscriptionId",{"kinds":[1]},{"kinds":[0]}]';

    test('might be instantiated with unnamed constructor', () {
      expect(
        RequestMessage(subscriptionId: subscriptionId).subscriptionId,
        equals(subscriptionId),
      );
      expect(RequestMessage().subscriptionId, isNotEmpty);
      expect(
        RequestMessage(
          filters: const [
            RequestFilter(kinds: [1]),
            RequestFilter(kinds: [0]),
          ],
        ).filters.length,
        equals(2),
      );
    });

    test('provides a way to add filters after instantiating', () {
      final RequestMessage requestMessage = RequestMessage();
      requestMessage.addFilter(const RequestFilter(kinds: [1]));
      requestMessage.addFilter(const RequestFilter(kinds: [2]));
      requestMessage.addFilter(const RequestFilter(authors: []));
      expect(requestMessage.filters.length, equals(3));
    });

    test('might be instantiated with fromJson constructor', () {
      final RequestMessage requestMessage =
          RequestMessage.fromJson(jsonDecode(rawMessage) as List<dynamic>);
      expect(requestMessage.subscriptionId, equals(subscriptionId));
      expect(requestMessage.filters.length, equals(2));
    });

    test('might be stringified to a raw message with toString method', () {
      final RequestMessage requestMessage = RequestMessage(
        subscriptionId: subscriptionId,
        filters: const [
          RequestFilter(kinds: [1]),
          RequestFilter(kinds: [0]),
        ],
      );
      expect(requestMessage.toString(), equals(rawMessage));
    });
  });
}
