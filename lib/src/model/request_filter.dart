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

  /// a list of event ids
  final List<String>? e;

  /// a list of event pubkeys
  final List<String>? p;

  /// an integer unix timestamp in seconds, events must be newer than this to pass
  final DateTime? since;

  /// an integer unix timestamp in seconds, events must be older than this to pass
  final DateTime? until;

  /// maximum number of events relays return in the initial query
  final int? limit;

  const RequestFilter({
    this.ids,
    this.authors,
    this.kinds,
    this.e,
    this.p,
    this.since,
    this.until,
    this.limit,
  });

  factory RequestFilter.fromJson(Map<String, dynamic> json) {
    return RequestFilter(
      ids: json['ids'] != null
          ? List<String>.from(json['ids'] as List<dynamic>)
          : null,
      authors: json['authors'] != null
          ? List<String>.from(json['authors'] as List<dynamic>)
          : null,
      kinds: json['kinds'] != null
          ? List<int>.from(json['kinds'] as List<dynamic>)
          : null,
      e: json['#e'] != null
          ? List<String>.from(json['#e'] as List<dynamic>)
          : null,
      p: json['#p'] != null
          ? List<String>.from(json['#p'] as List<dynamic>)
          : null,
      since: json['since'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['since'] as int) * 1000)
          : null,
      until: json['until'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['until'] as int) * 1000)
          : null,
      limit: json['limit'] != null ? json['limit'] as int : null,
    );
  }

  @override
  List<Object?> get props {
    return [
      ids,
      authors,
      kinds,
      e,
      p,
      since,
      until,
      limit,
    ];
  }

  RequestFilter copyWith({
    List<String>? Function()? ids,
    List<String>? Function()? authors,
    List<int>? Function()? kinds,
    List<String>? Function()? e,
    List<String>? Function()? p,
    DateTime? Function()? since,
    DateTime? Function()? until,
    int? Function()? limit,
  }) {
    return RequestFilter(
      ids: ids != null ? ids() : this.ids,
      authors: authors != null ? authors() : this.authors,
      kinds: kinds != null ? kinds() : this.kinds,
      e: e != null ? e() : this.e,
      p: p != null ? p() : this.p,
      since: since != null ? since() : this.since,
      until: until != null ? until() : this.until,
      limit: limit != null ? limit() : this.limit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ids != null) 'ids': ids,
      if (authors != null) 'authors': authors,
      if (kinds != null) 'kinds': kinds,
      if (e != null) '#e': e,
      if (p != null) '#p': p,
      if (since != null) 'since': since!.millisecondsSinceEpoch ~/ 1000,
      if (until != null) 'until': until!.millisecondsSinceEpoch ~/ 1000,
      if (limit != null) 'limit': limit,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
