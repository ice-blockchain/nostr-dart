import 'package:nostr_dart/nostr_dart.dart';

/// Representation of a Nostr NOTICE Message
///
/// Used to send human-readable error messages or other things from relays to clients.
///
/// [NoticeMessage] is sent from relay to client.
/// JSON representation is `["NOTICE", <message>]`
///
/// Usage example:
/// ```
/// subscription.messages.listen((RelayMessage event) {
///   if (event is NoticeMessage) {
///     print('Something went wrong: ${event.message}');
///   }
/// });
/// ```
class NoticeMessage extends RelayMessage {
  static const String type = 'NOTICE';

  final String message;

  NoticeMessage({
    required this.message,
  });

  factory NoticeMessage.fromJson(List<dynamic> json) {
    final [type, message as String] = json;

    if (type != NoticeMessage.type) {
      throw ArgumentError('json', 'Must be of type "${NoticeMessage.type}"');
    }

    return NoticeMessage(message: message);
  }

  @override
  List<Object> get props => [message];

  @override
  List<dynamic> toJson() {
    return [NoticeMessage.type, message];
  }
}
