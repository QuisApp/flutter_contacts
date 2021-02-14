## 0.1.2

* Properly delete events on iOS (https://github.com/QuisApp/flutter_contacts/issues/2)

## 0.1.1

* Fix date serialization on Android (https://github.com/QuisApp/flutter_contacts/issues/2)

## 0.1.0

* Support for vCard parsing and exporting
* Add `pedantic` static analyzer
* Make default values non-const so they can be mutated
* Add tests
* Update dependencies
* Deduplicate events
* Rename `socialMedia.dart` -> `social_media.dart`

## 0.0.7

* Bug fix with normalized phone number

## 0.0.6

* Added normalized phone numbers (android only)
* Deduplicate phone numbers and emails by default

## 0.0.5

* Improved README and dartdoc.
* Added option to `getFullContacts()` with high-res photos.
* Fixed bug on iOS where low-res photos were fetched instead of high-res and vice-versa.
* Better Kotlin null safety.

## 0.0.4

* `newContact()` now returns the full contact instead of ID / raw ID.

## 0.0.3

* Fix README typos.

## 0.0.2

* Fix support for iOS.

## 0.0.1

* Initial release.
