import 'package:nostr_dart/nostr_dart.dart';

class InvalidEventException implements Exception {
  final EventMessage event;

  InvalidEventException(this.event);

  @override
  String toString() {
    return 'InvalidEventException: $event';
  }
}
