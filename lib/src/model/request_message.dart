import 'dart:convert';

import 'package:nostr_dart/nostr_dart.dart';
import 'package:nostr_dart/src/crypto/utils.dart';

/// Representation of Nostr REQ message.
///
/// Used to request events and subscribe to new updates.
///
/// [RequestMessage] is sent from client to relay.
/// JSON representation is `["REQ", <subscription_id>, <filters JSON>...]`.
/// See [RequestFilter] for details about `filters JSON`
///
/// Upon receiving a REQ message, the relay queries its internal database and
/// returns events that match the filter, then store that filter and send again
/// all future events it receives to that same websocket until the websocket is closed.
///
/// A [RequestMessage] may contain multiple filters.
/// In this case, events that match any of the filters are to be returned, i.e.,
/// multiple filters are to be interpreted as || conditions.
///
/// [See more](https://github.com/nostr-protocol/nips/blob/master/01.md#from-client-to-relay-sending-events-and-creating-subscriptions)
class RequestMessage extends RelayMessage {
  static const String type = 'REQ';

  /// arbitrary, non-empty string of max length 64 chars that represents a subscription
  final String subscriptionId;

  final List<RequestFilter> filters;

  RequestMessage({String? subscriptionId, List<RequestFilter>? filters})
      : subscriptionId = subscriptionId ?? hexedRandomBytes(32),
        filters = filters ?? [];

  void addFilter(RequestFilter filter) {
    filters.add(filter);
  }

  factory RequestMessage.fromJson(List<dynamic> json) {
    final [type, subscriptionId as String, ...filters] = json;

    if (type != RequestMessage.type) {
      throw ArgumentError('json', 'Must be of type "${RequestMessage.type}"');
    }

    return RequestMessage(
      subscriptionId: subscriptionId,
      filters: filters
          .map(
            (filter) => RequestFilter.fromJson(filter as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<dynamic> toJson() {
    return [RequestMessage.type, subscriptionId, ...filters];
  }

  @override
  List<Object> get props => [subscriptionId, filters];

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
