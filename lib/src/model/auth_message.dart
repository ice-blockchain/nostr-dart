import 'package:nostr_dart/nostr_dart.dart';

/// Representation of a Nostr `AUTH` Message
///
/// Used for authentication between clients and relays as defined in [NIP-42](https://github.com/nostr-protocol/nips/blob/master/42.md).
///
/// [AuthMessage] is sent from relay to client.
/// JSON representation is `["AUTH", <challenge>]`
///
/// Usage example:
/// ```
/// subscription.messages.listen((RelayMessage event) {
///   if (event is AuthMessage) {
///     print('Received challenge: ${event.challenge}');
///   }
/// });
/// ```
class AuthMessage extends RelayMessage {
  static const String type = 'AUTH';

  final String challenge;

  AuthMessage({
    required this.challenge,
  });

  factory AuthMessage.fromJson(List<dynamic> json) {
    final [type, challenge as String] = json;

    if (type != AuthMessage.type) {
      throw ArgumentError('json', 'Must be of type "${AuthMessage.type}"');
    }

    return AuthMessage(challenge: challenge);
  }

  @override
  List<Object> get props => [challenge];

  @override
  List<dynamic> toJson() {
    return [AuthMessage.type, challenge];
  }

  @override
  String toString() {
    return '["$type", $challenge]';
  }
}
