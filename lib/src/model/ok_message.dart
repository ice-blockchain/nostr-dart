import 'package:nostr_dart/src/model/relay_message.dart';

/// Representation of a Nostr OK Message
///
/// Used to indicate acceptance or denial of an [EventMessage].
///
/// [NoticeMessage] is sent from relay to client.
/// JSON representation is `["OK", <event_id>, <true|false>, <message>]`
///
/// [OkMessage] is sent in response to [EventMessage],
/// it has the 3rd parameter set to true when an event has been accepted by the relay,
/// false otherwise. The 4th parameter MAY be empty when the 3rd is true,
/// otherwise it is a string containing a machine-readable single-word prefix
/// followed by a `:` and then a human-readable message.
/// The standardized machine-readable prefixes are: `duplicate`, `pow`, `blocked`,
/// `rate-limited`, `invalid`, and `error` for when none of that fits.
///
/// Some examples:
/// ```
/// ["OK", "b1a649ebe8...", true, ""]
/// ["OK", "b1a649ebe8...", true, "pow: difficulty 25>=24"]
/// ["OK", "b1a649ebe8...", true, "duplicate: already have this event"]
/// ["OK", "b1a649ebe8...", false, "blocked: you are banned from posting here"]
/// ["OK", "b1a649ebe8...", false, "blocked: please register your pubkey at https://my-expensive-relay.example.com"]
/// ["OK", "b1a649ebe8...", false, "rate-limited: slow down there chief"]
/// ["OK", "b1a649ebe8...", false, "invalid: event creation date is too far off from the current time. Is your system clock in sync?"]
/// ["OK", "b1a649ebe8...", false, "pow: difficulty 26 is less than 30"]
/// ["OK", "b1a649ebe8...", false, "error: could not connect to the database"]
/// ```
///
/// Usage example:
/// ```
/// final OkMessage result = await relay.sendEvent(event);
/// print("Event is accepted - ${result.accepted} ${result.message}");
/// ```
class OkMessage extends RelayMessage {
  static const String type = 'OK';

  final String eventId;

  final bool accepted;

  final String message;

  OkMessage({
    required this.eventId,
    required this.accepted,
    required this.message,
  });

  factory OkMessage.fromJson(List json) {
    final [type, eventId as String, accepted as bool, message as String] = json;

    if (type != OkMessage.type) {
      throw ArgumentError('json', 'Must be of type "${OkMessage.type}"');
    }

    return OkMessage(eventId: eventId, accepted: accepted, message: message);
  }

  @override
  List<Object> get props => [eventId, accepted, message];

  @override
  List<dynamic> toJson() {
    return [OkMessage.type, eventId, accepted, message];
  }
}
