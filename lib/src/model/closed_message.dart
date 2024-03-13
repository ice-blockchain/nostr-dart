import 'package:nostr_dart/nostr_dart.dart';

/// Representation of a Nostr `CLOSED` Message
///
/// Used to indicate that a subscription was ended on the server side.
///
/// [ClosedMessage] is sent from relay to client.
/// JSON representation is `["CLOSED", <subscription_id>, <message>]`.
///
/// [ClosedMessage] is sent in response to a [RequestMessage] when the relay
/// refuses to fulfill it. It can also be sent when a relay decides to kill
/// a subscription on its side before a client has disconnected or sent a [CloseMessage].
class ClosedMessage extends RelayMessage {
  static const String type = 'CLOSED';

  final String subscriptionId;

  final String message;

  ClosedMessage({
    required this.subscriptionId,
    required this.message,
  });

  factory ClosedMessage.fromJson(List<dynamic> json) {
    final [type, subscriptionId as String, message as String] = json;

    if (type != ClosedMessage.type) {
      throw ArgumentError('json', 'Must be of type "${ClosedMessage.type}"');
    }

    return ClosedMessage(subscriptionId: subscriptionId, message: message);
  }

  @override
  List<Object> get props => [subscriptionId, message];

  @override
  List<dynamic> toJson() {
    return [ClosedMessage.type, subscriptionId, message];
  }
}
