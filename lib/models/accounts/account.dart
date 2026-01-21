/// Contact account (e.g., Google account, iCloud account, local device account).
///
/// Contacts can belong to different accounts. On Android they're called accounts;
/// on iOS/macOS they're called containers. Each account has an ID, display name,
/// and type identifier (e.g., "com.google" for Google accounts).
///
/// Under the hood, contacts are stored as raw contacts within each account. When
/// you have the same person in multiple accounts (e.g., "John Doe" in both your
/// Google account and iCloud account), the system automatically links these raw
/// contacts together into a unified contact. This unified contact appears as a
/// single entry to users, combining data from all linked accounts. You can see
/// which accounts contributed data via `Contact.metadata.accounts`.
class Account {
  /// Account identifier.
  ///
  /// On iOS/macOS, this is the container identifier. On Android, this is
  /// always an empty string since Android accounts don't have stable IDs.
  final String id;

  /// Account display name (e.g., "user@gmail.com").
  final String name;

  /// Account type identifier (e.g., "com.google", "DeviceLocal").
  final String type;

  const Account({required this.id, required this.name, required this.type});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type};
  }

  static Account fromJson(Map json) => Account(
    id: json['id'] as String? ?? '',
    name: json['name'] as String,
    type: json['type'] as String,
  );

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          id == other.id &&
          name == other.name &&
          type == other.type);

  @override
  int get hashCode => Object.hash(id, name, type);

  Account copyWith({String? id, String? name, String? type}) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
  );
}
