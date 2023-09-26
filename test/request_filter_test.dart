import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Request Filter', () {
    const List<String> ids = [
      '325506ba08a49ceb9d1556597ec3f53e13c17c93789429dda37843d5806c6307',
    ];
    const List<String> authors = [
      'df4dcf54ad3e23ae64e0ae50eb39ca3b802f5aa09df85e02858b6958ba8f1e9e',
    ];
    const List<int> kinds = [1, 6, 7, 9735];
    const List<String> eventIds = [
      'ac8fe196c6cf7fe7562df1ef8b8431edbc14e741a842e0c2695ebebb344dcb1a',
    ];
    const List<String> publicKeys = [
      '9e65c9a8a30778440065603a58aa5ab07d14ffd870a14c6c76b63cdea96b8ba0',
    ];
    final DateTime since =
        DateTime.fromMillisecondsSinceEpoch(1577822400 * 1000);
    final DateTime until =
        DateTime.fromMillisecondsSinceEpoch(1577822600 * 1000);
    const int limit = 10;
    final String rawFilter =
        '{"ids":${jsonEncode(ids)},"authors":${jsonEncode(authors)},"kinds":${jsonEncode(kinds)},"#e":${jsonEncode(eventIds)},"#p":${jsonEncode(publicKeys)},"since":${since.millisecondsSinceEpoch ~/ 1000},"until":${until.millisecondsSinceEpoch ~/ 1000},"limit":$limit}';
    test('might be instantiated with unnamed constructor', () {
      final RequestFilter filter = RequestFilter(
        ids: ids,
        authors: authors,
        kinds: kinds,
        e: eventIds,
        p: publicKeys,
        since: since,
        until: until,
        limit: limit,
      );
      expect(filter.runtimeType, equals(RequestFilter));
      expect(filter.ids, equals(ids));
      expect(filter.authors, equals(authors));
      expect(filter.kinds, equals(kinds));
      expect(filter.e, equals(eventIds));
      expect(filter.p, equals(publicKeys));
      expect(filter.since, equals(since));
      expect(filter.until, equals(until));
      expect(filter.limit, equals(limit));
    });

    test('might be instantiated with fromJson constructor', () {
      final RequestFilter filter =
          RequestFilter.fromJson(jsonDecode(rawFilter) as Map<String, dynamic>);
      expect(filter.runtimeType, equals(RequestFilter));
      expect(filter.ids, equals(ids));
      expect(filter.authors, equals(authors));
      expect(filter.kinds, equals(kinds));
      expect(filter.e, equals(eventIds));
      expect(filter.p, equals(publicKeys));
      expect(filter.since, equals(since));
      expect(filter.until, equals(until));
      expect(filter.limit, equals(limit));
    });

    test('might be stringified to a raw filter with toString method', () {
      final RequestFilter filter =
          RequestFilter.fromJson(jsonDecode(rawFilter) as Map<String, dynamic>);
      expect(filter.toString(), equals(rawFilter));
    });
  });
}
