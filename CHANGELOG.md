## 0.0.45

* Set `null` for tags in `RequestFilter` `fromJson` if they are empty.

## 0.0.44

* Fix `RequestFilter` `copyWith` `tags` param type to match the `tags` field type.

## 0.0.43

* Add `connectUrl` to all the logs inside `NostrRelay` instead of `url`

## 0.0.42

* Add `connectUrl` (actual transport URL) and `connectUri` to `NostrRelay` to support proxy / failover connections while keeping a stable logical `url`
* Update `NostrRelay.connect` signature to use named parameters: `connectUrl` and `customSocket`
* Update example `relay_connection_custom_settings.dart` to pass `customSocket:` as a named argument

## 0.0.41

* Add `incomingMessageLoggingEnabled` and `outgoingMessageLoggingEnabled` getters to `NostrDartLogger` for controlling message logging

## 0.0.40

* Update `web_socket_client` lib

## 0.0.39

* Fix sending `CloseMessage` on `NostrRelay.unsubscribe`
* Fix casting socket connection state in `NostrRelay`

## 0.0.38

* Change all timestamps to microseconds since epoch

## 0.0.37

* Refactor: `NostrRelay.sentMessages` -> `NostrRelay.outgoingMessages`

## 0.0.36

* Add `NostrRelay.sentMessages` stream

## 0.0.35

* Change `EventMessage` time precision from seconds to microseconds

## 0.0.34

* Handle the case in `sendEvents` where the underlying connection is interrupted and the `messages` stream is closed. This can result in an empty `okMessages`, in which case a `SendEventException` should be thrown. Previously, we incorrectly assumed the send operation was successful due to the absence of `ok: false` events.

## 0.0.32

* Add `EventMessage.jsonPayload` getter

## 0.0.31

* Add log for incoming invalid event

## 0.0.30

* Handle `Reconnected` relay init state - case when the relay init is happening when no internet connection

## 0.0.29

* Revert `EventMessage.content` - make it required

## 0.0.28

* Fix `EventMessage.calculateEventId` with null content

## 0.0.27

* Make `EventMessage` `content` optional
* Add `EventMessage` `tags` normalization

## 0.0.26

* Add `url` to `NostrRelay.onClose` stream

## 0.0.25

* Introduced `onClose` stream in `NostrRelay` to notify listeners when the relay is closed

## 0.0.24

* Let `RequestFilter` tags be nested

## 0.0.23

* Replace tags in `RequestFilter` with generic tags Map

## 0.0.22

* Process `ClosedMessage` in message transform and `_isSubscriptionMessage`

## 0.0.21

* Add support for handling `ClosedMessage` in subscription message filtering

## 0.0.20

* Process `ClosedMessage` in message transform

## 0.0.19

* Revert optional keep subscription flag for request events method

## 0.0.18

* Add logger improvements
* Fix: Allow null for sig from json payload

## 0.0.17

* Add optional keep subscription flag for request events method

## 0.0.16

* Add auth message toString support
* Add authentication message support

## 0.0.15

* Update documentation

## 0.0.14

* Add `d` field to `RequestFilter`

## 0.0.13

* make `requestEvents` return `Stream<RelayMessage>` instead of `Stream<EventMessage>`
* expose `ClosedMessage`
* stop sending `CloseMessage` as a response to `ClosedMessage`

## 0.0.12

* close `relay.subscriptionsCountStreamController` on relay close

## 0.0.11

* Add `relay.subscriptionsCountStream` getter

## 0.0.10

* Add `EventSigner.privateKey` getter

## 0.0.9

* Breaking: `EventMessage.sig` is not optional
* Add `EventMessage.fromPayloadJson` factory constructor

## 0.0.8

* Breaking: `EventSigner.sign` now returns `FutureOr<String>` instead of `String`

## 0.0.7

* Add `q` field to `RequestFilter`

## 0.0.6

* Add `k` field to `RequestFilter`

## 0.0.5

* Breaking: `requestEvents` now returns `Stream<EventMessage>` instead of `Future<List<EventMessage>>`

## 0.0.4

* Update dependencies

## 0.0.3

* Make `SignatureVerifier.verify` method async
* Transform socket messages async way (asyncMap)

## 0.0.2

* Introduced the `NostrDart.configure` method, allowing users to pass a custom `SignatureVerifier`.
* Added a `search` field to the `RequestFilter` for enhanced filtering capabilities.
* Implemented the `relay.sendEvents` method, enabling the bulk sending of multiple events.

## 0.0.1

- Initial version.

## 0.0.26

* Introduced `onClose` stream in `NostrRelay` to notify listeners when the relay is closed.
