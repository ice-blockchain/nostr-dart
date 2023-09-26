// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer' as developer;

import 'package:logging/logging.dart' as logging;

final logging.Logger _logger = logging.Logger('Nostr');

StreamSubscription<logging.LogRecord>? _subscription;

void logInfo(Object? Function() log) =>
    _productionGuard(() => _logger.info(log()));

void logInfoWithError(
  (Object?, Object? error, StackTrace? stackTrace) Function() log,
) {
  _productionGuard(() {
    final (message, error, stackTrace) = log();
    _logger.info(message, error, stackTrace);
  });
}

void logWarning(Object? Function() log) =>
    _productionGuard(() => _logger.warning(log()));

void logWarningWithError(
  (Object? message, Object? error, StackTrace? stackTrace) Function() log,
) {
  _productionGuard(() {
    final (message, error, stackTrace) = log();
    _logger.warning(message, error, stackTrace);
  });
}

/// Method to set a desired logging output level.
///
/// ```
/// setNostrLogLevel(NostrLogLevel.ALL);
/// ```
void setNostrLogLevel(NostrLogLevel level) {
  logging.hierarchicalLoggingEnabled = true;
  _logger.level = level;

  _subscription?.cancel();

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

void _productionGuard(void Function() func) {
  assert(() {
    func();
    return true;
  }());
}

/// Logging output level.
///
/// The lower the integer value of a log level, the more verbose the output is.
class NostrLogLevel extends logging.Level {
  /// Turn on all levels
  static const NostrLogLevel ALL = NostrLogLevel('ALL', 0);

  /// Highly detailed tracing
  static const NostrLogLevel FINE = NostrLogLevel('FINE', 500);

  /// Informational messages
  static const NostrLogLevel INFO = NostrLogLevel('INFO', 800);

  /// Potential problems
  static const NostrLogLevel WARNING = NostrLogLevel('WARNING', 900);

  /// Turn off the logging
  static const NostrLogLevel OFF = NostrLogLevel('OFF', 2000);

  const NostrLogLevel(super.name, super.value);
}
