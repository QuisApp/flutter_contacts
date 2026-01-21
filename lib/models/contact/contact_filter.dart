/// Filter for querying contacts.
///
/// Supports filtering by contact IDs, group, name, phone, and email.
///
/// Filtering behavior:
/// - IDs: Exact matching on contact IDs
/// - Group: Contacts that belong to the specified group
/// - Name: Partial search (case-insensitive)
/// - Phone: Partial search on Android, full match only on iOS
/// - Email: Partial search on Android, full match only on iOS
///
/// **Platform Differences:**
/// - **Android**: Supports partial matching for phone and email (e.g., "555" matches "555-1234")
/// - **iOS**: Only supports full matching for phone and email (must match the complete value)
///
/// Example:
/// ```dart
/// final filter = ContactFilter.ids(['id1', 'id2']);
/// final contacts = await FlutterContacts.getAll(filter: filter);
/// ```
class ContactFilter {
  /// Filter type enum
  final _FilterType _type;
  final dynamic _value;

  ContactFilter._(this._type, this._value);

  /// Filter by contact IDs (exact matching).
  factory ContactFilter.ids(List<String> ids) =>
      ContactFilter._(_FilterType.ids, ids);

  /// Filter by a single group.
  factory ContactFilter.group(String groupId) =>
      ContactFilter._(_FilterType.group, groupId);

  /// Filter by name (partial search, case-insensitive).
  factory ContactFilter.name(String name) =>
      ContactFilter._(_FilterType.name, name);

  /// Filter by phone number.
  ///
  /// **Platform behavior:**
  /// - Android: Partial search (e.g., "555" matches "555-1234")
  /// - iOS: Full match only (must match the complete phone number)
  factory ContactFilter.phone(String phone) =>
      ContactFilter._(_FilterType.phone, phone);

  /// Filter by email address.
  ///
  /// **Platform behavior:**
  /// - Android: Partial search (e.g., "gmail" matches "user@gmail.com")
  /// - iOS: Full match only (must match the complete email address)
  factory ContactFilter.email(String email) =>
      ContactFilter._(_FilterType.email, email);

  /// Converts the filter to a JSON map for platform communication.
  Map<String, dynamic> toJson() => switch (_type) {
    _FilterType.ids => {'id': _value},
    _FilterType.group => {'group': _value},
    _FilterType.name => {'name': _value},
    _FilterType.phone => {'phone': _value},
    _FilterType.email => {'email': _value},
  };
}

/// Internal enum for filter types
enum _FilterType { ids, group, name, phone, email }
