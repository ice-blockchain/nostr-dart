import 'dart:convert';

import 'package:equatable/equatable.dart';

/// The base class for all relay messages.
abstract class RelayMessage extends Equatable {
  List<dynamic> toJson();

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
