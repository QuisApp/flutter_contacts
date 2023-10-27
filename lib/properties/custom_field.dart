import 'package:flutter_contacts/vcard.dart';

/// Labeled CustomField.
class CustomField {
  /// CustomField name.
  String name;

  /// CustomField label.
  String label;

  CustomField(
    this.name,
    this.label,
  );

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        (json['name'] as String?) ?? '',
        json['label'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'label': label,
      };

  @override
  int get hashCode => name.hashCode ^ label.hashCode;

  @override
  bool operator ==(Object o) =>
      o is CustomField && o.name == name && o.label == label;

  @override
  String toString() => 'CustomField(name=$name, label=$label';

  /// Custom Fields are output as a vCard NOTE. Some tools such as Google Contacts
  /// will append custom fields to existing notes. However, the vCard format
  /// does support multiple note fields.
  List<String> toVCard() {
    return ['NOTE:${vCardEncode('$label: $name')}'];
  }
}
