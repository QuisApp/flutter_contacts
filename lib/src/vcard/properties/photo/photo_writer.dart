import 'dart:convert';
import '../../../../models/contact/contact.dart';
import '../../core/version.dart';
import '../../utils/mime_type.dart';
import '../../utils/formatting/params.dart';
import '../../writer/formatter.dart';

/// Writes PHOTO property.
///
/// RFC sections:
/// - vCard 2.1: PHOTO with ENCODING=BASE64
/// - vCard 3.0: RFC 2426 Section 3.1.4 (PHOTO with ENCODING=b)
/// - vCard 4.0: RFC 6350 Section 6.2.4 (PHOTO MUST be a URI, data: URI for inline images)
void writePhoto(StringBuffer buffer, Contact contact, VCardVersion version) {
  if (contact.photo == null) return;

  final bytes = contact.photo!.fullSize ?? contact.photo!.thumbnail;
  if (bytes == null || bytes.isEmpty) return;

  final mimeType = detectImageMimeType(bytes);

  final base64Data = base64Encode(bytes);
  final String photoValue;
  final List<String>? photoParams;

  switch (version) {
    case VCardVersion.v21:
      photoValue = base64Data;
      photoParams = [
        '${paramName('TYPE', version)}=$mimeType',
        '${paramName('ENCODING', version)}=BASE64',
      ];
      break;
    case VCardVersion.v3:
      photoValue = base64Data;
      photoParams = [
        '${paramName('TYPE', version)}=$mimeType',
        '${paramName('ENCODING', version)}=b',
      ];
      break;
    case VCardVersion.v4:
      photoValue = 'data:image/${mimeType.toLowerCase()};base64,$base64Data';
      photoParams = null;
      break;
  }

  writeProperty(
    buffer,
    'PHOTO',
    photoValue,
    version: version,
    params: photoParams,
    isBase64: true,
  );
}
