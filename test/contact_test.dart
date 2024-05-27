import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('new contact should have no null values except for photo', () {
    final contact = Contact();
    final json = contact.toJson();
    final nulls = nullValues(json);
    expect(nulls, ['/thumbnail', '/photo']);
  });

  test('add phone numbers', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('github.com/QuisApp/flutter_contacts'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'insert') {
          final c = methodCall.arguments[0];
          c['displayName'] = '${c['name']['first']} ${c['name']['last']}';
          c['id'] = '12345';
          return c;
        }
        return null;
      },
    );
    final newContact = Contact()
      ..name = Name(first: 'John', last: 'Doe')
      ..phones = [
        Phone('555-123-4567'),
        Phone('555-999-9999', label: PhoneLabel.work)
      ];
    final returnedContact = await newContact.insert();
    expect(returnedContact.displayName, 'John Doe');
    expect(returnedContact.phones.length, 2);
  });
}

List<String> nullValues(dynamic x, {String path = ''}) {
  if (x is Map) {
    var nulls = <String>[];
    x.forEach((k, v) => nulls.addAll(nullValues(v, path: '$path/$k')));
    return nulls;
  } else if (x is List) {
    return nullValues(x.asMap(), path: path);
  } else if (x == null) {
    return [path];
  } else {
    return [];
  }
}
