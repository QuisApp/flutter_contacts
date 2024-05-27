## 1.1.8

* Upgrade gradle, add null-safety in example_full.

## 1.1.7+1

* Fix for AGP <4.2 (https://github.com/QuisApp/flutter_contacts/issues/127) - thanks trfiladelfo

## 1.1.7

* Add feature to pre-populate fields in openExternalInsert() - thanks sakchhams
* Fix openExternalView and openExternalEdit on iOS (https://github.com/QuisApp/flutter_contacts/issues/91, https://github.com/QuisApp/flutter_contacts/issues/70)
* Support Gradle 8 (https://github.com/QuisApp/flutter_contacts/issues/123)
* Fix fetching notes on iOS - thanks starshipcoder and yassinsameh
* Fix bug with address label default on iOS - thanks MohamedAl-Kainai and yassinsameh

## 1.1.6

* Update kotlin/gradle versions (https://github.com/QuisApp/flutter_contacts/issues/69)

## 1.1.5+1

* Fix null pointer error (https://github.com/QuisApp/flutter_contacts/pull/71 - thanks anggrayudi)
* Update README

## 1.1.5

* Edit groups (iOS) / labels (Android) and group/label membership

## 1.1.4

* Fix gradle compile error (https://github.com/QuisApp/flutter_contacts/issues/49)

## 1.1.3

* Fix social media custom label bug (https://github.com/QuisApp/flutter_contacts/issues/42)

## 1.1.2

* Read/write starred contacts on Android (https://github.com/QuisApp/flutter_contacts/issues/37)
* Fix vCard photo encoding (https://github.com/QuisApp/flutter_contacts/issues/34)

## 1.1.1+2

* Update comments

## 1.1.1+1

* Update README

## 1.1.1

* Fetch groups (iOS) / labels (Android) and containers (iOS) / accounts (Android) (https://github.com/QuisApp/flutter_contacts/issues/29)
* Ability to request read-only permissions (https://github.com/QuisApp/flutter_contacts/issues/25)

## 1.1.0+4

* Load rawContact instead of contactId after update, since Android sometimes changes the contactId

## 1.1.0+3

* Fix withThumbnail on iOS

## 1.1.0+2

* Fix hashCode and ==

## 1.1.0+1

* Fix a diacritics bug

## 1.1.0

* Add ability to open external contact app to view, edit, pick or insert contacts (https://github.com/QuisApp/flutter_contacts/issues/16)

## 1.0.0+1

* Fix for permission handler on Android (https://github.com/QuisApp/flutter_contacts/pull/17) - thanks @scroollocker
* Fix type cast error on iOS 14.5 (https://github.com/QuisApp/flutter_contacts/issues/19) - thanks @jadasi

## 1.0.0

* Stable release 🎉
* Follow-up fix for https://github.com/QuisApp/flutter_contacts/issues/9
* Fix https://github.com/QuisApp/flutter_contacts/issues/14

## 0.3.3+1

* Fix https://github.com/QuisApp/flutter_contacts/issues/9

## 0.3.3

* Fix lint warning

## 0.3.2

* Remove unused dependency

## 0.3.1

* Change Dart SDK version requirements

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
