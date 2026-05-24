import 'package:flutter/foundation.dart';

import '../contact/contact.dart';
import '../../utils/json_helpers.dart';

/// A vCard property not modeled natively by [Contact] (e.g. an app-specific
/// `X-` extension like `X-MYAPP-FAVORITE-COLOR`).
///
/// Populated by `FlutterContacts.vCard.import` for every property the parser
/// doesn't recognize, and written back out by `.export`. Lets apps round-trip
/// `X-` extension properties through vCard without losing data.
///
/// Access via the [VCardContactExtras] extension on [Contact]:
/// ```dart
/// final contact = FlutterContacts.vCard.import(vcard).first;
/// contact.extras.forEach(print);
///
/// contact.extras = [VCardExtra(name: 'X-MYAPP-FOO', value: 'bar')];
/// FlutterContacts.vCard.export(contact);
/// ```
class VCardExtra {
  /// Property name, uppercased.
  final String name;

  /// Decoded value (vCard escapes and quoted-printable already resolved).
  final String value;

  /// Property parameters. A null value means a bare flag (vCard 2.1 style).
  final Map<String, String?> params;

  /// Group prefix for grouped properties (e.g. `item1` in `item1.X-FOO`).
  final String? group;

  const VCardExtra({
    required this.name,
    required this.value,
    this.params = const {},
    this.group,
  });

  @override
  String toString() => JsonHelpers.formatToString('VCardExtra', {
    'name': name,
    'value': value,
    'params': params.isNotEmpty ? params : null,
    'group': group,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VCardExtra &&
          name == other.name &&
          value == other.value &&
          group == other.group &&
          mapEquals(params, other.params));

  @override
  int get hashCode =>
      Object.hash(name, value, group, Object.hashAllUnordered(params.entries));
}

final _extras = Expando<List<VCardExtra>>('vcard_extras');

/// Attaches [VCardExtra]s to a [Contact] for vCard round-tripping. Backed by
/// an [Expando], so extras don't affect [Contact] equality, [Contact.toJson],
/// or [Contact.copyWith] — and are tied to instance identity (a `copyWith`d
/// contact starts with no extras).
extension VCardContactExtras on Contact {
  List<VCardExtra> get extras => _extras[this] ?? const [];

  set extras(List<VCardExtra> value) =>
      _extras[this] = value.isEmpty ? null : List.unmodifiable(value);
}
