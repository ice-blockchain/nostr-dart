// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer' as developer;

import 'package:logging/logging.dart' as logging;

final logging.Logger _logger = logging.Logger.detached('Nostr');

StreamSubscription<logging.LogRecord>? _subscription;

final logInfo = _logger.info;

final logWarning = _logger.warning;

/// Method to set a desired logging output level.
///
/// ```
/// setNostrLogLevel(NostrLogLevel.ALL);
/// ```
Future<void> setNostrLogLevel(NostrLogLevel level) async {
  logging.hierarchicalLoggingEnabled = true;
  _logger.level = level;

  await _subscription?.cancel();

  _subscription = _logger.onRecord.listen((logging.LogRecord record) {
    developer.log(
      record.message,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

/// Logging output level.
///
/// The lower the integer value of a log level, the more verbose the output is.
class NostrLogLevel extends logging.Level {
  /// Turn on all levels
  static const NostrLogLevel ALL = NostrLogLevel('ALL', 0);

  /// Informational messages
  static const NostrLogLevel INFO = NostrLogLevel('INFO', 800);

  /// Potential problems
  static const NostrLogLevel WARNING = NostrLogLevel('WARNING', 900);

  /// Turn off the logging
  static const NostrLogLevel OFF = NostrLogLevel('OFF', 2000);

  const NostrLogLevel(super.name, super.value);
}
