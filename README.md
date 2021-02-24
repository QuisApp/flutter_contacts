# flutter_contacts

[![pub](https://img.shields.io/pub/v/flutter_contacts?label=version&style=flat-square)](https://pub.dev/packages/flutter_contacts)
[![pub points](https://badges.bar/flutter_contacts/pub%20points)](https://pub.dev/packages/flutter_contacts/score)
[![popularity](https://badges.bar/flutter_contacts/popularity)](https://pub.dev/packages/flutter_contacts/score)
[![likes](https://badges.bar/flutter_contacts/likes)](https://pub.dev/packages/flutter_contacts/score)

Flutter plugin to read, create, update, delete and observe native contacts on Android and iOS, with vCard support

For a minimalistic example, take a look at `example/`. You can write a full-fledged contacts app with it – see `example_full/` to see how.

## Demo

![demo](https://user-images.githubusercontent.com/1289004/101141809-ab165c00-35c9-11eb-90ff-b10318b13f16.gif)

## Features

* **Fetch** all contacts
* **Create** new contact
* **Update** existing contact
* **Delete** contacts
* **Observe** contact database changes
* **Export** to and **parse** from vCard format
* Fetch all details for a given contact, including:
    * Photo (low / high resolution)
    * Phones
    * Emails
    * Company / job title
    * Postal addresses
    * Websites
    * Birthday / events
    * Instant messaging / social profiles
    * Notes
    * Labels (such as "main" or "work" for phones)

## Warning: breaking changes in version 0.2.0

Version 0.2.0 introduces breaking changes compared to version 0.1.3:
* The data model now has `photo` (high-resolution) and `thumbnail` (low-resolution) as
  separate fields instead of just one field; you can use the getter `photoOrThumbnail`
  where you previously used `photo`.
* `Event.date` has been replaced with components `Event.year` (which can be null on both
  Android and iOS), `Event.month` and `Event.day`.
* `getFullContact()` has been renamed `getContact()`.
* `updateContact()`, `insertContact()` and `deleteContacts()` still exist but we
  recommend using the convenience methods `contact.update()`, `contact.insert()` and
  `contact.delete()` instead.
* `updateContact()` now fails unless the contact has been fetched completely.
* What used to be called "details" is now called "properties" (phones, emails, etc), for
  example in `getContacts(withProperties: true)`.
* `Contact.create()` is now simply `Contact()`
* `final deleteListener = FlutterContacts.onChange(() => print('...')); deleteListener();`
  is now `final listener = () => print('...'); FlutterContacts.addListener(listener); FlutterContacts.removeListener(listener);`.

## Usage

```dart
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

if (await Permission.contacts.request().isGranted) {
    /// Get all contacts (IDs and names only)
    List<Contact> contacts = await FlutterContacts.getContacts();

    /// Get all fields (phones, emails, photo, job, etc) for a given contact
    Contact contact = await FlutterContacts.getContact(contacts.first.id);

    /// Listen to contacts database changes
    FlutterContacts.addListener(() => print('Contact DB changed'));

    /// Create contact
    Contact newContact = Contact()
        ..name = Name(first: 'John', last: 'Doe')
        ..phones = [Phone('555-123-4567'), Phone('555-999-9999', label: PhoneLabel.work)];
    await newContact.insert();

    /// Update contact
    newContact.emails.add(Email('john.doe@example.com'));
    await newContact.update();

    /// Export to vCard
    String vCard = newContact.toVCard();

    /// Import from vCard
    Contact importedContact = Contact.fromVCard(
        'BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'N:;Joe;;;\n'
        'TEL;TYPE=HOME:123456\n'
        'END:VCARD');
)

    /// Delete contact
    await newContact.delete();
}
```

## Data model

### Essential data model (enough for most use cases)

```dart
class Contact {
    String id;
    String displayName;
    Uint8List photo; // high-resolution
    Uint8List thumbnail; // low-resolution
    Name name;
    List<Phone> phones;
    List<Email> emails;
    List<Address> addresses;
}

class Name {
    String first;
    String last;
}

class Phone {
    String number;
}

class Email {
    String address;
}

class Address {
    String address;
}
```

### Complete data model (for power users)

```dart
class Contact {
    // Always fetched
    String id;
    String displayName;

    // Fetched when calling getContacts(withPhoto: true)
    Uint8List photo;

    // Fetched when calling getContacts(withThumbnail: true)
    Uint8List thumbnail;

    // Fetched when calling getContacts(withProperties: true)
    Name name;
    List<Phone> phones;
    List<Email> emails;
    List<Address> addresses;
    List<Organization> organizations;
    List<Website> websites;
    List<SocialMedia> socialMedias;
    List<Event> events;
    List<Note> notes;
    List<Account> accounts;
}

class Name {
    String first;
    String last;
    String middle;
    String prefix;             // e.g. "Dr" in American names
    String suffix;             // e.g. "Jr" in American names
    String nickname;
    String firstPhonetic;
    String lastPhonetic;
    String middlePhonetic;
}

class Phone {
    String number;
    String normalizedNumber;  // e.g. +12345678900 for +1 (234) 567-8900 (android only)
    PhoneLabel label;         // https://cutt.ly/4hXHFq2, default PhoneLabel.mobile
    String customLabel;       // if label == PhoneLabel.custom
    bool isPrimary;           // phone number called by default (android only)
}

class Email {
    String address;
    EmailLabel label;         // https://cutt.ly/zhXHGba, default EmailLabel.home
    String customLabel;       // if label == EmailLabel.custom
    bool isPrimary;           // email address used by default (android only)
}

class Address {
    String address;           // formatted address (always available)
    AddressLabel label;       // https://cutt.ly/ShXHFm6, default AddressLabel.home
    String customLabel;       // if label == AddressLabel.custom
    String street;            // street name and house number
    String pobox;             // android only
    String neighborhood;      // android only
    String city;
    String state;             // US state; also region/department/county on android
    String postalCode;
    String country;
    String isoCountry;        // ISO 3166-1 alpha-2 standard (iOS only)
    String subAdminArea       // region/county (iOS only)
    String subLocality;       // anything else (iOS only)
}

class Organization {
    String company;           // company name
    String title;             // job title
    String department;        // department
    String jobDescription;    // job description (android only)
    String symbol;            // ticker symbol (android only)
    String phoneticName;
    String officeLocation;    // android only
}

class Website {
    String url;
    WebsiteLabel label;       // https://cutt.ly/JhXH5CF, default WebsiteLabel.homepage
    String customLabel;       // if label == WebsiteLabel.custom
}

class SocialMedia {
    String userName;          // handle/username/login
    SocialMediaLabel label;   // https://cutt.ly/9hXJwFH, default SocialMediaLabel.other
    String customLabel;       // if label == SocialMediaLabel.custom
}

class Event {
    int year;                 // can be null
    int month;
    int day;
    EventLabel label;         // https://cutt.ly/vhXJtAW, default EventLabel.birthday
    String customLabel;       // if label == EventLabel.customLabel
}

class Note {
    String note;              // not available on iOS13+, see https://cutt.ly/HhXJoMR
}

class Account {               // for debug purposes (android only)
    String rawId;             // raw contact ID
    String type;              // e.g. com.google or com.facebook.messenger
    String name;              // e.g. john.doe@gmail.com
    List<String> mimetypes;   // list of android mimetypes
}
```

### Default values

Apart from `photo`, `thumbnail`, and `Event.year`, nothing can be `null`. String values
default to `''`, boolean values to `false`, lists to `[]`, `DateTime` to Jan 1 1970,
integers (`Event.month` and `Event.day`) to 1, and enums as indicated above.

### Android/iOS availability

Some fields are only available on iOS, others only on Android. Concretely it means that
if, for example, you save a contact with
`contact.addresses[0].subLocality = 'some place'` on Android, you will lose that
information when fetching it again.

Regarding labels, some are present in both (e.g. `PhoneLabel.mobile`), others only on
one platform (e.g. `PhoneLabel.iPhone`). If you try, for example, to save a contact with
`contact.phones[0].label = PhoneLabel.iPhone` on Android, it will instead get saved with
`label = PhoneLabel.custom` and `customLabel = 'iPhone'`.

## Installation

1. Add `permission_handler: ^5.1.0+2` (or higher) to the `dependencies` in
   `pubspec.yaml`: this is the package that allows you to request contact permissions.
1. Add the following key/value pair to your app's `Info.plist` (for iOS):
    ```xml
    <plist version="1.0">
    <dict>
        ...
        <key>NSContactsUsageDescription</key>
        <string>Reason why we need access to the contact list</string>
    </dict>
    </plist>
    ```
1. Add the following `<uses-permissions>` tags to your app's `AndroidManifest.xml` (for
   Android):
    ```xml
    <manifest xmlns:android="http://schemas.android.com/apk/res/android" ...>
        <uses-permission android:name="android.permission.READ_CONTACTS"/>
        <uses-permission android:name="android.permission.WRITE_CONTACTS"/>
        <application ...>
        ...
    ```
