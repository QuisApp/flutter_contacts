# flutter_contacts

Flutter plugin to read, create, update, delete and observe native contacts on Android and iOS.

For a minimalistic example, take a look at `example/`. You can write a full-fledged contacts app with it – see `example_full/` to see how.

## Features

* List all contacts
* Create new contact
* Update existing contact
* Delete contacts
* Observe contact database changes
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
