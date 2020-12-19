# flutter_contacts

Flutter plugin to read, create, update, delete and observe native contacts on Android and iOS.

For a minimalistic example, take a look at `example/`. You can write a full-fledged contacts app with it – see `example_full/` to see how.

## Features

* **Fetch** all contacts
* **Create** new contact
* **Update** existing contact
* **Delete** contacts
* **Observe** contact database changes
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

★ Exclusive `flutter_contacts` features:
* **Maximum compability** with native contacts: fetching a contact and saving it back
  doesn't alter it
* Contacts correctly **sorted**, ignoring case and diacritics
* No *"zombie contacts"* on Android (fake or duplicate contacts that wouldn't appear in
  your default contact app)

## Demo

![demo](https://user-images.githubusercontent.com/1289004/101141809-ab165c00-35c9-11eb-90ff-b10318b13f16.gif)

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
    FlutterContacts.onChange(() => print('Contact DB changed'));

    /// Create contact
    Contact newContact = Contact.create()
        ..name = Name(first: 'John', last: 'Doe')
        ..phones = [Phone('555-123-4567'), Phone('555-999-9999', label: PhoneLabel.work)];
    newContact = await FlutterContacts.newContact(newContact);

    /// Update contact
    newContact.emails.add(Email('john.doe@example.com'));
    await FlutterContacts.updateContact(newContact);

    /// Delete contact
    await FlutterContacts.deleteContact(newContact.id);
}
```

## Data model

### Essential data model (enough for most use cases)

```dart
class Contact {
    String id;
    String displayName;
    Uint8List photo;
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

    // Fetched when calling:
    //   - getContact()
    //   - getContacts(withPhotos: true)
    //   - getFullContacts(withPhotos: true)
    // Photo is low-resolution, unless calling:
    //   - getContact()
    //   - getContacts(withPhotos: true, useHighResolutionPhotos: true)
    //   - getFullContacts(withPhotos: true, useHighResolutionPhotos: true)
    Uint8List photo;

    // Fetched when calling:
    //   - getContact()
    //   - getFullContacts()
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
    DateTime date;
    EventLabel label;         // https://cutt.ly/vhXJtAW, default EventLabel.birthday
    String customLabel;       // if label == EventLabel.customLabel
    bool noYear;              // iOS only
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

Apart from `photo`, nothing can be `null`. String values default to `''`, boolean values
to `false`, lists to `[]`, `DateTime` to Jan 1 1970, and enums as indicated above.

### Android/iOS availability

Some fields are only available on iOS, others only on Android. Concretely it means that
if, for example, you save a contact with `contact.events[0].noYear = true` on Android,
you will lose that information when fetching it again.

Regarding labels, some are present in both (e.g. `PhoneLabel.mobile`), others only on
one platform (e.g. `PhoneLabel.iPhone`). If you try, for example, to save a contact with
`contact.phones[0].label = PhoneLabel.iPhone` on Android, it will instead get saved with
`label = PhoneLabel.custom` and `customLabel = 'iPhone'`.

## Installation

1. Add `json_serializable: ^3.5.0` (or higher) to the `dev_dependencies` in `pubspec.yaml`.
1. Add `permission_handler: ^5.0.0+hotfix.3` (or higher) to the `dependencies` in `pubspec.yaml`: this is the package that allows you to request contact permissions.
1. Add the following key/value pair to your app's `Info.plist` (for iOS):
    ```xml
    <plist version="1.0">
    <dict>
        ...
        <key>NSContactsUsageDescription</key>
        <string>Access contact list</string>
    </dict>
    </plist>
    ```
1. Add the following `<uses-permissions>` tags to your app's `AndroidManifest.xml` (for Android):
    ```xml
    <manifest xmlns:android="http://schemas.android.com/apk/res/android" ...>
        <uses-permission android:name="android.permission.READ_CONTACTS"/>
        <uses-permission android:name="android.permission.WRITE_CONTACTS"/>
        <application ...>
        ...
    ```
