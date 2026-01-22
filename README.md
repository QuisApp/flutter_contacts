# 📞 Flutter Contacts

> **The fastest, most complete Flutter plugin for native contacts** 🚀

Get, create, update, and delete contacts with **comprehensive property support**. Includes groups, accounts, vCard import/export, native dialogs, real-time change listeners, permissions management, and platform-specific APIs across **Android**, **iOS**, and **macOS**.

[![pub version](https://img.shields.io/pub/v/flutter_contacts?color=0288D1&logo=flutter&logoColor=white&logoSize=auto&style=for-the-badge&include_prereleases)](https://pub.dev/packages/flutter_contacts) [![pub likes](https://img.shields.io/pub/likes/flutter_contacts?color=26A69A&style=for-the-badge)](https://pub.dev/packages/flutter_contacts) [![pub dm](https://img.shields.io/pub/dm/flutter_contacts?color=5C6BC0&style=for-the-badge)](https://pub.dev/packages/flutter_contacts)
[![license](https://img.shields.io/badge/license-MIT-546E7A?logo=github&logoColor=white&style=for-the-badge)](https://github.com/QuisApp/flutter_contacts/blob/master/LICENSE)

---

## ⚡ Why Flutter Contacts?

- 🏆 **Benchmarks:** up to **7x faster** reads, 100x faster bulk operations
- 📈 **Scalable** - handles **10,000+ contacts** smoothly via batch operations
- 🛡️ **Read/write** with comprehensive property support
- 🔍 **Efficient filtering** by name, phone, email, group, and more
- 👥 **Accounts & Groups** for multi-account contact management
- 📇 **vCard import/export** supporting all properties and formats
- 🔔 **Real-time change listeners** with change tracking
- 🎨 **Native dialogs** for picking, viewing, editing contacts
- 📱 **Android-specific APIs** - Blocked Numbers, Ringtones, SIM contacts
- 🌍 **Cross-platform** - Android, iOS, and macOS

---

## 🚀 Quick Start

### 1. Add Dependency

```yaml
dependencies:
  flutter_contacts: ^2.0.0
```

### 2. Configure Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to...</string>
```

<details>
<summary><b>iOS Notes Entitlement</b></summary>

To access contact notes on iOS, add the `com.apple.developer.contacts.notes` entitlement and set `FlutterContacts.config.enableIosNotes = true`. See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.contacts.notes).

</details>

### 3. Basic Usage

```dart
import 'package:flutter_contacts/flutter_contacts.dart';

// Request permissions
final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
if (status == PermissionStatus.granted) {
  // Get all contacts (fast - defaults to IDs and display names only)
  List<Contact> contacts = await FlutterContacts.getAll();
  
  // Get a specific contact with all properties
  Contact? contact = await FlutterContacts.get(
    contacts.first.id!,
    properties: ContactProperties.all,
  );
}
```

📂 See [`example/`](example/) for a minimal example, or [flutter_contacts_example](https://github.com/QuisApp/flutter_contacts_example) for a full-fledged contacts app.

---

## 🧠 Core Concepts

### 📐 API Structure

| Category | API | Purpose |
| --- | --- | --- |
| **Core CRUD** | `FlutterContacts.get()`, `.getAll()`, `.create()`, `.createAll()`, `.update()`, `.updateAll()`, `.delete()`, `.deleteAll()` | Contact operations |
| **Feature APIs** | `FlutterContacts.accounts`, `.groups`, `.permissions`, `.vCard`, `.native`, `.config` | Specialized features |
| **Platform APIs** | `FlutterContacts.sim` (Android), `.profile` (Android/macOS), `.blockedNumbers` (Android), `.ringtones` (Android) | Platform-specific |
| **Streams** | `FlutterContacts.onDatabaseChange`, `.onContactChange` | Real-time notifications |

### ⚡ Selective Fetching

By default, `get()` and `getAll()` fetch only **ID and display name**. Specify `properties` for additional fields.

```dart
// List view: display name is always fetched, add thumbnails
await FlutterContacts.getAll(
  properties: {ContactProperty.photoThumbnail},
);

// Detail view: all properties
await FlutterContacts.get(contactId, properties: ContactProperties.all);
```

### 🔒 Data Integrity

Only fetched properties can be updated. This prevents accidental data loss.

```dart
// Fetch name + phone only
var contact = await FlutterContacts.get(id, properties: {ContactProperty.name, ContactProperty.phone});

// Only name and phone are saved; email changes would be ignored
contact = contact.copyWith(name: Name(givenName: 'Jane'));
await FlutterContacts.update(contact);
```

<details>
<summary><b>Unified Contact Model</b></summary>

On Android, multiple "raw contacts" from different accounts are automatically merged into unified contacts. On iOS, the same merging happens behind the scenes. The plugin provides a single, consistent API across both platforms.

</details>

<details>
<summary><b>Accounts & Groups</b></summary>

**Accounts** (containers on iOS) organize contacts by source - Google, iCloud, local device. **Groups** (labels on Android) organize contacts within an account. When creating a contact, you can specify which account to use; otherwise, it uses the default.

</details>

---

## 📊 Performance Benchmarks

**Tested with ~2,000 contacts** on real devices (iPhone 7, Pixel 6):

```
                          Fetch all contacts: ID + display name (ms)

                          ━━━━━━━━━━━━ iOS ━━━━━━━━━━━━  ━━━━━━━━━━ Android ━━━━━━━━━━━

                          ◀─── faster  slower ───▶        ◀─── faster slower ───▶
flutter_contacts v2       █████░░░░░░░░░░░░░░░░░░░  117   ██████████░░░░░░░░░░░░░   424
fast_contacts             █████░░░░░░░░░░░░░░░░░░░  127   ███████░░░░░░░░░░░░░░░░   304
contacts_service_plus     █████████████░░░░░░░░░░░  462   ███████████████░░░░░░░░   668
flutter_contacts v1       ███████████████████████░  803   ███████████████████████  1075
```

| V2 vs V1            | iOS           | Android        |
| ------------------- | ------------- | -------------- |
| **Read speed**      | 1.6–7x faster | 2–5x faster    |
| **Bulk create**     | 4x faster     | 5x faster      |
| **Bulk delete**     | 34x faster    | 140x faster    |

_See the [benchmark repository](https://github.com/QuisApp/flutter_contacts_benchmark) for detailed methodology and feature comparison._

---

## 📚 Core API

### Read

```dart
// Single contact with all properties
Contact? contact = await FlutterContacts.get(id, properties: ContactProperties.all);

// All contacts with filtering
List<Contact> contacts = await FlutterContacts.getAll(
  properties: {ContactProperty.name, ContactProperty.phone},
  filter: ContactFilter.name('John'),
  limit: 100,
);
```

Both `get()` and `getAll()` default to fetching only ID + display name. Specify `properties` for additional fields.

**Filters:** `ContactFilter.name()`, `.phone()`, `.email()`, `.group()`, `.ids()`. Phone/email filters use partial match on Android, full match on iOS.

### Create

```dart
String id = await FlutterContacts.create(contact, account: account);
List<String> ids = await FlutterContacts.createAll([contact1, contact2]);
```

### Update

```dart
// Must fetch first (see Data Integrity above)
await FlutterContacts.update(contact);
await FlutterContacts.updateAll([contact1, contact2]);
```

### Delete

```dart
await FlutterContacts.delete(id);
await FlutterContacts.deleteAll([id1, id2, id3]);
```

---

## 🔧 Feature APIs

<details>
<summary><b>🔐 Permissions</b></summary>

```dart
bool has = await FlutterContacts.permissions.has(PermissionType.read);
PermissionStatus status = await FlutterContacts.permissions.check(PermissionType.read);
PermissionStatus result = await FlutterContacts.permissions.request(PermissionType.readWrite);
await FlutterContacts.permissions.openSettings();
```

**Types:** `PermissionType.read`, `.write`, `.readWrite` (on iOS, all are equivalent).

</details>

<details>
<summary><b>👤 Accounts</b></summary>

```dart
List<Account> accounts = await FlutterContacts.accounts.getAll();
Account? defaultAccount = await FlutterContacts.accounts.getDefault();
await FlutterContacts.accounts.showDefaultPicker(); // Android only
```

</details>

<details>
<summary><b>👥 Groups</b></summary>

```dart
Group? group = await FlutterContacts.groups.get(groupId, withContactCount: true);
List<Group> groups = await FlutterContacts.groups.getAll(accounts: [account]);
Group created = await FlutterContacts.groups.create('Family', account: account);
await FlutterContacts.groups.update(group);
await FlutterContacts.groups.delete(groupId);
await FlutterContacts.groups.addContacts(groupId: groupId, contactIds: [id1, id2]);
await FlutterContacts.groups.removeContacts(groupId: groupId, contactIds: [id1]);
List<Group> contactGroups = await FlutterContacts.groups.getOf(contactId);
```

</details>

<details>
<summary><b>📇 vCard</b></summary>

```dart
String vCard = FlutterContacts.vCard.export(contact, version: VCardVersion.v3);
String vCards = FlutterContacts.vCard.exportAll([contact1, contact2]);
List<Contact> contacts = FlutterContacts.vCard.import(vCardString);
```

Supports vCard 2.1, 3.0, and 4.0.

</details>

<details>
<summary><b>🎨 Native Dialogs</b> (Android & iOS)</summary>

No permissions required - uses system UI.

```dart
String? pickedId = await FlutterContacts.native.showPicker();
await FlutterContacts.native.showViewer(contactId);
String? editedId = await FlutterContacts.native.showEditor(contactId);
String? createdId = await FlutterContacts.native.showCreator(contact: prefill);
```

</details>

<details>
<summary><b>🔔 Change Listeners</b></summary>

```dart
FlutterContacts.onDatabaseChange.listen((_) => refreshUI());

FlutterContacts.onContactChange.listen((changes) {
  for (final change in changes) {
    print('${change.type}: ${change.contactId}');
  }
});
```

</details>

<details>
<summary><b>📱 SIM Contacts</b> (Android only)</summary>

```dart
List<Contact> simContacts = await FlutterContacts.sim.get();
```

SIM contacts are read-only and typically contain only name and phone.

</details>

<details>
<summary><b>👤 Profile / "Me" Card</b> (Android & macOS)</summary>

```dart
Contact? me = await FlutterContacts.profile.get(properties: ContactProperties.all);
```

Returns the device owner's profile (Android) or "Me" card (macOS). Not available on iOS.

</details>

<details>
<summary><b>🚫 Blocked Numbers</b> (Android only)</summary>

Requires app to be default phone app. See [example manifest](https://github.com/QuisApp/flutter_contacts/blob/master/example/android/app/src/main/AndroidManifest.xml).

```dart
if (await FlutterContacts.blockedNumbers.isAvailable()) {
  bool isBlocked = await FlutterContacts.blockedNumbers.isBlocked('+1234567890');
  List<Phone> blocked = await FlutterContacts.blockedNumbers.getAll();
  await FlutterContacts.blockedNumbers.block('+1234567890');
  await FlutterContacts.blockedNumbers.blockAll([number1, number2]);
  await FlutterContacts.blockedNumbers.unblock('+1234567890');
  await FlutterContacts.blockedNumbers.unblockAll([number1, number2]);
  await FlutterContacts.blockedNumbers.openDefaultAppSettings();
}
```

</details>

<details>
<summary><b>🔔 Ringtones</b> (Android only)</summary>

```dart
String? uri = await FlutterContacts.ringtones.pick(type: RingtoneType.ringtone);
Ringtone? ringtone = await FlutterContacts.ringtones.get(uri, withMetadata: true);
List<Ringtone> all = await FlutterContacts.ringtones.getAll(type: RingtoneType.ringtone);
String? defaultUri = await FlutterContacts.ringtones.getDefaultUri(RingtoneType.ringtone);
await FlutterContacts.ringtones.setDefaultUri(RingtoneType.ringtone, uri);
await FlutterContacts.ringtones.play(uri);
await FlutterContacts.ringtones.stop();
```

</details>

<details>
<summary><b>⚙️ Configuration</b></summary>

```dart
FlutterContacts.config.enableIosNotes = true; // Requires iOS entitlement
```

</details>

---

## 📋 Data Model

**Quick Reference:** A `Contact` contains an optional `id`, auto-generated `displayName`, and lists of properties (`phones`, `emails`, `addresses`, etc.). Most properties support labels (home, work, mobile, etc.) and custom labels.

<details>
<summary><b>Contact Structure</b></summary>

```dart
class Contact {
  final String? id;                    // Stable identifier
  final String? displayName;           // Read-only, auto-generated
  final Photo? photo;
  final Name? name;
  final List<Phone> phones;
  final List<Email> emails;
  final List<Address> addresses;
  final List<Organization> organizations;
  final List<Website> websites;
  final List<SocialMedia> socialMedias;
  final List<Event> events;            // Birthdays, anniversaries
  final List<Relation> relations;
  final List<Note> notes;
  final bool? isFavorite;              // Android only
  final String? customRingtone;        // Android only
  final bool? sendToVoicemail;        // Android only
}
```

</details>

<details>
<summary><b>Property Types</b></summary>

```dart
// Name
Name(
  givenName: 'John',
  familyName: 'Smith',
  middleName: 'Q',
  prefix: 'Dr.',
  suffix: 'Jr.',
)

// Phone, Email, Address
Phone('555-1234')
Phone('555-1234', label: Label(PhoneLabel.mobile))
Email('john@example.com', label: Label(EmailLabel.work))
Address(
  street: '123 Main St',
  city: 'New York',
  state: 'NY',
  postalCode: '10001',
  label: Label(AddressLabel.home),
)

// Organization
Organization(
  organizationName: 'FlutterCorp',
  jobTitle: 'Software Engineer',
  departmentName: 'Engineering',
)

// Photo
Photo(fullSize: imageBytes)
```

> **Address Usage:** Prefer component fields (`street`, `city`, `state`, etc.) when creating/editing. The formatted `address` field is available when reading and is guaranteed to be present.

> **Photo Usage:** When creating/updating, set `Photo(fullSize: imageBytes)` - the system automatically generates the thumbnail. When reading, fetch `ContactProperty.photoThumbnail` (fast) for contact lists, `ContactProperty.photoFullRes` (slower) for detail views, or both. Access via `contact.photo?.thumbnail` or `contact.photo?.fullSize`.

> **Note:** The examples above show common fields. See [lib/models/](https://github.com/QuisApp/flutter_contacts/tree/master/lib/models) for the complete list of all available fields and properties.

</details>

<details>
<summary><b>Labels</b></summary>

Most properties support **labels** (home, work, mobile, etc.) and **custom labels**:

```dart
// Standard label
Phone('555-1234', label: Label(PhoneLabel.mobile))

// Custom label
Phone('555-1234', label: Label(PhoneLabel.custom, customLabel: 'Emergency'))
```

**Platform Support:** Some labels are platform-specific (e.g., `PhoneLabel.appleWatch` is iOS-only, `PhoneLabel.workMobile` is Android-only). Unsupported labels are automatically converted to custom labels with the original name preserved.

**See [lib/models/](https://github.com/QuisApp/flutter_contacts/tree/master/lib/models) for complete data model documentation.**

</details>

---

## ⚠️ Platform Limitations

<details>
<summary><b>iOS & macOS</b></summary>

**Not Available:**
- APIs: `ringtones`, `blockedNumbers`, `sim`, `profile` (iOS), `native` (macOS)
- Properties: `isFavorite`, `customRingtone`, `sendToVoicemail`
- Fields: `Phone.isPrimary`, `Phone.normalizedNumber`, `Email.isPrimary`, `Address.poBox`, `Address.neighborhood`, `Organization.jobDescription`, `Organization.symbol`, `Organization.officeLocation`
- Some Android-specific labels (auto-converted to custom)

**Limits:** One organization, one note, one birthday per contact.

**Filtering:** Phone and email filters only support full match (not partial).

**iOS Notes:** Requires the `com.apple.developer.contacts.notes` entitlement and `FlutterContacts.config.enableIosNotes = true`. See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.contacts.notes).

</details>

<details>
<summary><b>Android</b></summary>

**Not Available:**
- Fields: `Name.previousFamilyName`, `Address.isoCountryCode`, `Address.subAdministrativeArea`, `Address.subLocality`
- Some iOS-specific labels (auto-converted to custom)

**Special Features:**
- **SIM Contacts:** Read-only, typically name + phone only
- **Blocked Numbers:** Requires app to be default phone app

</details>

---

## 🔄 Migrating from v1

If you're using [flutter_contacts v1](https://pub.dev/packages/flutter_contacts/versions/1.1.9+2):

| v1 | v2 |
| --- | --- |
| `FlutterContacts.getContacts()` | `FlutterContacts.getAll()` |
| `FlutterContacts.getContact(id)` | `FlutterContacts.get(id)` |
| `contact.insert()` | `FlutterContacts.create(contact)` |
| `FlutterContacts.requestPermission()` | `FlutterContacts.permissions.request(PermissionType.readWrite)` |
| `FlutterContacts.addListener()` | `FlutterContacts.onDatabaseChange.listen()` |
| `contact.toVCard()` | `FlutterContacts.vCard.export(contact)` |
| `PhoneLabel.mobile` | `Label(PhoneLabel.mobile)` |
| `FlutterContacts.openExternalView(id)` | `FlutterContacts.native.showViewer(id)` |
| `FlutterContacts.openExternalPick()` | `FlutterContacts.native.showPicker()` |
| `FlutterContacts.openExternalEdit(id)` | `FlutterContacts.native.showEditor(id)` |
| `FlutterContacts.openExternalInsert()` | `FlutterContacts.native.showCreator()` |

---

## 🤝 Contributing

We'd love your help making this plugin even better. Found a bug? Have a feature idea? Want to improve the docs?

- 🐛 [Report an issue](https://github.com/QuisApp/flutter_contacts/issues)
- 💡 [Suggest a feature](https://github.com/QuisApp/flutter_contacts/issues)
- 🔧 [Submit a pull request](https://github.com/QuisApp/flutter_contacts/pulls)
- 📖 Improve the documentation

Every contribution, big or small, makes a difference. Thank you for helping make Flutter Contacts better for everyone.

---

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💝 Support

Flutter Contacts is maintained in my free time. If this plugin has been helpful for your project, consider supporting its development. Your support helps me continue maintaining and improving it.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G11OWJA4)

---

## 🙏 Acknowledgments

Special thanks to all contributors and users who have helped shape this plugin.

---

<div align="center">

**Made with ❤️ for the Flutter community**

[⭐ Star us on GitHub](https://github.com/QuisApp/flutter_contacts) | [📖 Documentation](https://pub.dev/documentation/flutter_contacts/latest/) | [🐛 Report Issues](https://github.com/QuisApp/flutter_contacts/issues)

</div>
