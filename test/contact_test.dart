import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel('github.com/QuisApp/flutter_contacts')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'new') {
      final c = methodCall.arguments as Map;
      c['displayName'] = '${c['name']['first']} ${c['name']['last']}';
      c['id'] = '12345';
      return c;
    }
    return null;
  });

  test('new contact should have no null values except for photo', () {
    final contact = Contact.create();
    final json = contact.toJson(includePhoto: true);
    final nulls = nullValues(json);
    expect(nulls, ['/photo']);
  });

  test('add phone numbers', () async {
    final newContact = Contact.create()
      ..name = Name(first: 'John', last: 'Doe')
      ..phones = [
        Phone('555-123-4567'),
        Phone('555-999-9999', label: PhoneLabel.work)
      ];
    final returnedContact = await FlutterContacts.newContact(newContact);
    expect(returnedContact.displayName, 'John Doe');
    expect(returnedContact.phones.length, 2);
  });

  test('normalized names', () {
    var c = Contact.create();
    expect((c..displayName = 'Édouard').normalizedName, 'edouard');
    expect((c..displayName = '  john  ').normalizedName, 'john');
    expect((c..displayName = 'Zażółć gęślą jaźń').normalizedName,
        'zazolc gesla jazn');
    expect((c..displayName = '🍾🏝🐶').normalizedName, '🍾🏝🐶');
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
