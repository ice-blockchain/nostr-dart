import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Representation of `REQ` message filter.
///
/// The class is used in conjunction with [RequestMessage] and determines
/// what events will be sent in the corresponding subscription.
/// [See more](https://github.com/nostr-protocol/nips/blob/master/01.md#from-client-to-relay-sending-events-and-creating-subscriptions)
class RequestFilter extends Equatable {
  /// a list of event ids
  final List<String>? ids;

  /// a list of lowercase pubkeys, the pubkey of an event must be one of these
  final List<String>? authors;

  /// a list of a kind numbers
  final List<int>? kinds;

  /// a map of tag name to list of values
  final Map<String, List<String>>? tags;

  /// an integer unix timestamp in seconds, events must be newer than this to pass
  final DateTime? since;

  /// an integer unix timestamp in seconds, events must be older than this to pass
  final DateTime? until;

  /// maximum number of events relays return in the initial query
  final int? limit;

  /// search query
  final String? search;

  const RequestFilter({
    this.ids,
    this.authors,
    this.kinds,
    this.tags,
    this.since,
    this.until,
    this.limit,
    this.search,
  });

  factory RequestFilter.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> tags = {};

    for (final entry in json.entries) {
      if (entry.key.startsWith('#')) {
        tags[entry.key] = List<String>.from(entry.value as List<dynamic>);
      }
    }

    return RequestFilter(
      ids: json['ids'] != null ? List<String>.from(json['ids'] as List<dynamic>) : null,
      authors: json['authors'] != null ? List<String>.from(json['authors'] as List<dynamic>) : null,
      kinds: json['kinds'] != null ? List<int>.from(json['kinds'] as List<dynamic>) : null,
      tags: tags,
      since: json['since'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['since'] as int) * 1000)
          : null,
      until: json['until'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['until'] as int) * 1000)
          : null,
      limit: json['limit'] != null ? json['limit'] as int : null,
      search: json['search'] != null ? json['search'] as String : null,
    );
  }

  @override
  List<Object?> get props {
    return [
      ids,
      authors,
      kinds,
      tags,
      since,
      until,
      limit,
      search,
    ];
  }

  RequestFilter copyWith({
    List<String>? Function()? ids,
    List<String>? Function()? authors,
    List<int>? Function()? kinds,
    Map<String, List<String>>? Function()? tags,
    DateTime? Function()? since,
    DateTime? Function()? until,
    int? Function()? limit,
    String? Function()? search,
  }) {
    return RequestFilter(
      ids: ids != null ? ids() : this.ids,
      authors: authors != null ? authors() : this.authors,
      kinds: kinds != null ? kinds() : this.kinds,
      tags: tags != null ? tags() : this.tags,
      since: since != null ? since() : this.since,
      until: until != null ? until() : this.until,
      limit: limit != null ? limit() : this.limit,
      search: search != null ? search() : this.search,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      if (ids != null) 'ids': ids,
      if (authors != null) 'authors': authors,
      if (kinds != null) 'kinds': kinds,
      if (since != null) 'since': since!.millisecondsSinceEpoch ~/ 1000,
      if (until != null) 'until': until!.millisecondsSinceEpoch ~/ 1000,
      if (limit != null) 'limit': limit,
      if (search != null) 'search': search,
    };

    if (tags != null) {
      for (final entry in tags!.entries) {
        json[entry.key] = entry.value;
      }
    }

    return json;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
