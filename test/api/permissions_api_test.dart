import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/api/permissions_api.dart';
import 'package:flutter_contacts/models/permissions/permission_type.dart';
import 'package:flutter_contacts/models/permissions/permission_status.dart';
import '../support/test_channels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('flutter_contacts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('check sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => 'granted',
    );

    final status = await PermissionsApi.instance.check(PermissionType.read);

    expect(status, PermissionStatus.granted);
    expect(log.last.method, 'permissions.check');
    expect(log.last.arguments['type'], 'read');
  });

  test('request sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => 'granted',
    );

    final status = await PermissionsApi.instance.request(PermissionType.read);

    expect(status, PermissionStatus.granted);
    expect(log.last.method, 'permissions.request');
    expect(log.last.arguments['type'], 'read');
  });
}
