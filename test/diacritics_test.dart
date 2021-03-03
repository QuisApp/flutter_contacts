import 'package:flutter_contacts/diacritics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remove diacritics', () {
    expect(removeDiacritics('Édouard'), 'Edouard');
    expect(removeDiacritics("Être contesté, c'est être constaté"),
        "Etre conteste, c'est etre constate");
    expect(removeDiacritics('ÇƑⓃꝘǊǩꜩß'), 'CFNQNJktzss');
  });
}
