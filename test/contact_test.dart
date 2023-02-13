import 'package:flutter/foundation.dart';
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
    const MethodChannel('github.com/QuisApp/flutter_contacts')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'insert') {
        final c = methodCall.arguments[0];
        c['displayName'] = '${c['name']['first']} ${c['name']['last']}';
        c['id'] = '12345';
        return c;
      }
    });
    final newContact = Contact(name: Name(first: 'John', last: 'Doe'), phones: [
      Phone('555-123-4567'),
      Phone('555-999-9999', label: PhoneLabel.work)
    ]);

    final returnedContact = await newContact.insert();
    expect(returnedContact.displayName, 'John Doe');
    expect(returnedContact.phones.length, 2);
  });

  group('Contacts CopyWith()', () {
    test('When using copyWith() with attributes, new object is not a reference',
        () {
      final contact1 = Contact(id: '1', displayName: 'x');
      final contact2 = contact1.copyWith(displayName: 'y');

      expect(contact1.displayName == contact2.displayName, false);
    });
    test(
        'When using copyWith() with attributes, validate equality '
        'operator function detects objects difference', () {
      final contact1 = Contact(id: '1', displayName: 'x');
      final contact2 = contact1.copyWith(id: '2');

      expect(contact1 == contact2, false);
    });
    test(
        'When using copyWith() on a contact with photo and passing null,'
        "the contact's photo should be equal to null ", () async {
      var bytes = Uint8List.fromList([1]);

      final contact = Contact(id: '1', displayName: 'x', photo: bytes);
      final contactNoPhoto = contact.copyWith(photo: null, thumbnail: null);

      expect(contact.photo, isNotNull);
      expect(contactNoPhoto.photo, isNull);
      expect(contactNoPhoto.thumbnail, isNull);
    });
    test(
        'When using copyWith() on a contact with photo and passing another image,'
        "the contact's photo should be equal to the other image ", () async {
      var image = Uint8List.fromList([1]);
      final contact = Contact(id: '1', photo: image, thumbnail: image);

      var image2 = Uint8List.fromList([2]);
      final contactChangePhoto =
          contact.copyWith(photo: image2, thumbnail: image2);

      expect(contactChangePhoto.photo == image2, true);
      expect(contactChangePhoto.thumbnail == image2, true);
    });
    test(
        'When using copyWith() on a contact with NO photo and passing another image,'
        "the contact's photo should be equal to the other image ", () async {
      final contact = Contact(id: '1', photo: null);

      var image = Uint8List.fromList([2]);
      final contactChangePhoto =
          contact.copyWith(photo: image, thumbnail: image);

      expect(contactChangePhoto.photo == image, true);
      expect(contactChangePhoto.thumbnail == image, true);
    });
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
