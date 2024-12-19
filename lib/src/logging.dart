// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:logger/web.dart';

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.dateAndTime,
    lineLength: 1000,
  ),
);

void logInfo(dynamic message, [Object? error, StackTrace? stackTrace]) =>
    log.i(message, error: error, stackTrace: stackTrace);

void logWarning(dynamic message, [Object? error, StackTrace? stackTrace]) =>
    log.w(message, error: error, stackTrace: stackTrace);

/// Method to set a desired logging output level.
///
/// ```
/// setNostrLogLevel(NostrLogLevel.ALL);
/// ```
Future<void> setNostrLogLevel(Level level) async {
  Logger.level = level;
}

/// Logging output level.
///
/// The lower the integer value of a log level, the more verbose the output is.
class NostrLogLevel {
  /// Turn on all levels
  static const Level ALL = Level.all;

  /// Informational messages
  static const Level INFO = Level.info;

  /// Potential problems
  static const Level WARNING = Level.warning;

  /// Turn off the logging
  static const Level OFF = Level.off;
}
