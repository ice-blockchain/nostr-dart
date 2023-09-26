import 'package:nostr_dart/src/model/event_message.dart';

class InvalidEventException implements Exception {
  final EventMessage event;

  InvalidEventException(this.event);

  @override
  String toString() {
    return 'InvalidEventException: $event';
  }
}
