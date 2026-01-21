import 'dart:convert';
import '../../../../models/properties/photo.dart';
import '../../core/property.dart';

/// Parses PHOTO property into Photo object.
///
/// Handles both data URIs (vCard 4.0: "data:image/jpeg;base64,...") and raw base64 (vCard 2.1/3.0).
Photo? parsePhoto(VCardProperty prop) {
  final value = prop.value;
  final base64Data = value.startsWith('data:')
      ? (value.contains('base64,')
            ? value.substring(value.indexOf(',') + 1)
            : null)
      : value;

  if (base64Data == null) return null;

  // Remove whitespace (folding can introduce spaces)
  final cleanBase64 = base64Data.replaceAll(RegExp(r'\s+'), '');
  if (cleanBase64.isEmpty) return null;

  final photoData = base64Decode(cleanBase64);
  if (photoData.isEmpty) return null;

  return Photo(fullSize: photoData);
}
