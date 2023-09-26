import 'package:nostr_dart/nostr_dart.dart';

/// Representation of a Nostr CLOSE Message
///
/// Used to stop previous subscriptions.
///
/// [CloseMessage] is sent from client to relay.
/// JSON representation is `["CLOSE", <subscription_id>]`.
///
/// The class is not intended to be used directly.
/// It is used internally in [NostrRelay.unsubscribe] method.
class CloseMessage extends RelayMessage {
  static const String type = 'CLOSE';

  final String subscriptionId;

  CloseMessage({
    required this.subscriptionId,
  });

  factory CloseMessage.fromJson(List<dynamic> json) {
    final [type, subscriptionId as String] = json;

    if (type != CloseMessage.type) {
      throw ArgumentError('json', 'Must be of type "${CloseMessage.type}"');
    }

    return CloseMessage(subscriptionId: subscriptionId);
  }

  @override
  List<Object> get props => [subscriptionId];

  @override
  List<dynamic> toJson() {
    return [CloseMessage.type, subscriptionId];
  }
}
