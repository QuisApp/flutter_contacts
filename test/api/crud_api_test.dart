import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/api/crud_api.dart';
import 'package:flutter_contacts/models/contact/contact_property.dart';
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

  test('get sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => <String, dynamic>{'id': '1'},
    );

    final contact = await CrudApi.instance.get(
      '1',
      properties: {ContactProperty.name},
    );

    expect(contact?.id, '1');
    expect(log.last.method, 'crud.get');
    expect(log.last.arguments['id'], '1');
  });

  test('getAll sends expected method call', () async {
    final log = await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => <Map<String, dynamic>>[],
    );

    final results = await CrudApi.instance.getAll(
      properties: {ContactProperty.phone},
    );

    expect(results, isEmpty);
    expect(log.last.method, 'crud.getAll');
  });

  test(
    'getAll throws ArgumentError when dataMimetypes is requested without identifiers',
    () async {
      expect(
        () => CrudApi.instance.getAll(
          properties: {ContactProperty.dataMimetypes},
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'get throws ArgumentError when dataMimetypes is requested without identifiers',
    () async {
      expect(
        () => CrudApi.instance.get(
          'some-id',
          properties: {ContactProperty.dataMimetypes},
        ),
        throwsArgumentError,
      );
    },
  );

  test('getAll accepts dataMimetypes when paired with identifiers', () async {
    await setUpMockMethodChannel(
      methodChannel,
      handler: (call) async => <Map<String, dynamic>>[],
    );

    final results = await CrudApi.instance.getAll(
      properties: {ContactProperty.identifiers, ContactProperty.dataMimetypes},
    );
    expect(results, isEmpty);
  });
}
