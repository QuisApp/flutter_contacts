import '../models/contact/contact.dart';
import '../models/vcard/vcard_version.dart';
import '../src/vcard/writer/vcard_writer.dart';
import '../src/vcard/reader/vcard_reader.dart';

/// vCard import/export API.
///
/// Handles converting contacts to and from vCard format (RFC 2426, RFC 6350).
class VCardApi {
  const VCardApi._();

  static const instance = VCardApi._();

  /// Exports a single contact to vCard format.
  ///
  /// [version] - vCard version to use.
  ///
  /// Returns the vCard string.
  String export(Contact contact, {VCardVersion version = VCardVersion.v3}) =>
      VCardWriter.write(contact, version);

  /// Exports multiple contacts to vCard format.
  ///
  /// [version] - vCard version to use.
  ///
  /// Returns the concatenated vCard string.
  String exportAll(
    List<Contact> contacts, {
    VCardVersion version = VCardVersion.v3,
  }) => contacts.map((c) => VCardWriter.write(c, version)).join('\r\n');

  /// Imports contacts from a vCard string.
  ///
  /// Returns the parsed contacts.
  List<Contact> import(String vCard) => VCardReader.parse(vCard);
}
