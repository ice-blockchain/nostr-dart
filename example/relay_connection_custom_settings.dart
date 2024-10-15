// ignore_for_file: avoid_print

import 'package:nostr_dart/nostr_dart.dart';

void main() async {
  setNostrLogLevel(NostrLogLevel.ALL);

  const String url = 'wss://relay.damus.io';

  final WebSocket customSocket = WebSocket(
    Uri.parse(url),
    timeout: const Duration(seconds: 10),
    backoff: const ConstantBackoff(Duration(seconds: 5)),
  );

  final NostrRelay relay = await NostrRelay.connect(url, customSocket);

  final KeyStore keyStore = KeyStore.generate();

  final EventMessage event = EventMessage.fromData(
    signer: keyStore,
    kind: 0,
    content: '{"name":"test"}',
  );

  await relay.sendEvent(event);

  print("Event is sent");
}
