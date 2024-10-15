class SendEventException implements Exception {
  final String code;

  SendEventException(this.code);

  @override
  String toString() {
    return 'SendEventException: $code';
  }
}
