## 0.0.23

* Replace tags in `RequestFilter` with generic tags Map

## 0.0.23

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
