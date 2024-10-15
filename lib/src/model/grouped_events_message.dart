import 'package:nostr_dart/nostr_dart.dart';

// TODO: add a comment
class GroupedEventsMessage extends RelayMessage {
  static const String type = 'EVENT';

  GroupedEventsMessage({
    required this.events,
  });

  final List<EventMessage> events;

  @override
  List<Object?> get props => [events];

  @override
  List toJson() {
      return [EventMessage.type, ...events.map((event) => event.toJson().last)];
  }
}
