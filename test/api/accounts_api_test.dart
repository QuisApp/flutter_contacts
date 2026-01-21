import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/api/accounts_api.dart';
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

  test('getAll sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => <Map<String, dynamic>>[],
    );

    final accounts = await AccountsApi.instance.getAll();

    expect(accounts, isEmpty);
    expect(log.last.method, 'accounts.getAll');
  });

  test('getDefault sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => <String, dynamic>{
        'id': 'acc-1',
        'name': 'Account',
        'type': 'local',
      },
    );

    final account = await AccountsApi.instance.getDefault();

    expect(account?.id, 'acc-1');
    expect(log.last.method, 'accounts.getDefault');
  });
}
