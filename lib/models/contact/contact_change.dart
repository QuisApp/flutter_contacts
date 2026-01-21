import 'contact_change_type.dart';

export 'contact_change_type.dart';

/// A single contact change.
///
/// This represents one change to a single contact. If multiple contacts change,
/// multiple [ContactChange] objects will be emitted, one per contact.
class ContactChange {
  /// The type of change that occurred.
  final ContactChangeType type;

  /// The ID of the contact that changed.
  final String contactId;

  const ContactChange({required this.type, required this.contactId});
}
