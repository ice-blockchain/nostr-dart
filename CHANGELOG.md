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
