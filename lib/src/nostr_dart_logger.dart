/// Abstract interface for logging operationslibrary;
abstract interface class NostrDartLogger {
  void info(String message, [Object? error, StackTrace? stackTrace]);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  bool get incomingMessageLoggingEnabled;
  bool get outgoingMessageLoggingEnabled;
}
