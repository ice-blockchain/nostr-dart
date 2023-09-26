import 'package:nostr_dart/src/model/relay_message.dart';

/// Representation of a Nostr EOSE Message
///
/// Used to indicate the end of stored events and the beginning of events newly received in real-time.
///
/// [EoseMessage] is sent from relay to client.
/// JSON representation is `["EOSE", <subscription_id>]`.
///
/// Usage example:
/// ```
/// subscription.messages.listen((RelayMessage event) {
///   if (event is EoseMessage) {
///     print('All the requested stored events are received');
///   }
/// });
/// ```
class EoseMessage extends RelayMessage {
  static const String type = 'EOSE';

  final String subscriptionId;

  EoseMessage({
    required this.subscriptionId,
  });

  factory EoseMessage.fromJson(List<dynamic> json) {
    final [type, subscriptionId as String] = json;

    if (type != EoseMessage.type) {
      throw ArgumentError('json', 'Must be of type "${EoseMessage.type}"');
    }

    return EoseMessage(subscriptionId: subscriptionId);
  }

  @override
  List<Object> get props => [subscriptionId];

  @override
  List<dynamic> toJson() {
    return [EoseMessage.type, subscriptionId];
  }
}
