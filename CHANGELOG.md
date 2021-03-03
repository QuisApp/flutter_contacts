## 0.3.0

* Migrated to null-safety

## 0.2.2

* Support for requesting permissions
* Option to return non-visible contacts on Android and raw contacts on Android/iOS
  (https://github.com/QuisApp/flutter_contacts/issues/5)

## 0.2.1

* Format

## 0.2.0

* Not backward compatible!
* Photo and thumbnail are now distinct fields
* `Event.date` is now `Event.year`, `Event.month`, `Event.day`
* Convenience methods `contact.insert()`, `contact.update()`, `contact.delete()`
* Much more advanced vCard parsing and exporting (to version 3.0 and 4.0)
* We can now add multiple listeners
* Removed dependencies to `build_runner` and `json_serializable`
* Implemented `toString()`, `hashCode` and `operator==` for contact and properties
* Support for notes on iOS13+ by setting
  `FlutterContacts.config.includeNotesOnIos13AndAbove = true`
* Added tests

## 0.1.3

* Remove extra print statements

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
