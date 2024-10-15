# nostr_dart

A Dart Library for making [Nostr](https://nostr.com/) clients.

## Features

Add this library to your Dart app to:
* Connect to Nostr relays
* Start subscriptions using filters and get a handy Stream of decoded and verified messages
* Send Nostr events to relays
* Deal with Nostr Cryptography - sign and verify messages, generate private and public keys

## Getting started

This lib is in beta. Please use with caution and file and potential issues you see on our issue tracker.

## Usage

```dart
void main() async {
  NostrDart.configure(NostrLogLevel.ALL);

  final NostrRelay relay = await NostrRelay.connect('wss://relay.damus.io');

  final RequestMessage requestMessage = RequestMessage()
      ..addFilter(const RequestFilter(kinds: [1], limit: 5))
      ..addFilter(
        RequestFilter(kinds: const [0], limit: 1, since: DateTime(2020)),
      );

  final NostrSubscription subscription = relay.subscribe(requestMessage);

  final StreamSubscription listener = subscription.messages.listen((event) {
    if (event is EoseMessage) {
      print('Stored events are received');
    }
  });

  await Future.delayed(const Duration(seconds: 2));

  relay.unsubscribe(subscription.id);
  listener.cancel();

  final KeyStore keyStore = KeyStore.generate();

  final EventMessage event = EventMessage.fromData(
    keyStore: keyStore,
    kind: 0,
    content: '{"name":"test"}',
  );

  final OkMessage result = await relay.sendEvent(event);

  print("Event is accepted - ${result.accepted} $result");
}
```
