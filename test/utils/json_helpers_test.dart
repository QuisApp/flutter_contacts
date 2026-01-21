import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/utils/json_helpers.dart';
import 'package:flutter_contacts/models/permissions/permission_type.dart';

void main() {
  test('decode handles null gracefully', () {
    final result = JsonHelpers.decode(null, (json) => json['id'] as String);
    expect(result, isNull);
  });

  test('decodeList handles null gracefully', () {
    final result = JsonHelpers.decodeList(null, (json) => json['id'] as String);
    expect(result, isEmpty);
  });

  test('decodeEnum handles null gracefully', () {
    final result = JsonHelpers.decodeEnum(
      null,
      PermissionType.values,
      PermissionType.read,
    );
    expect(result, PermissionType.read);
  });
}
