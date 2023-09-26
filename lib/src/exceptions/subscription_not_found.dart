class SubscriptionNotFoundException implements Exception {
  final String subscriptionId;

  SubscriptionNotFoundException(this.subscriptionId);

  @override
  String toString() {
    return 'SubscriptionNotFoundException: subscriptionId=$subscriptionId';
  }
}
