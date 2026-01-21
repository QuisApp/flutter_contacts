import 'dart:typed_data';

/// Detects MIME type from image bytes (basic detection).
///
/// Returns common MIME types for JPEG, PNG, GIF, WEBP, BMP.
/// Defaults to 'JPEG' if detection fails or bytes are too short.
String detectImageMimeType(Uint8List bytes) {
  if (bytes.length < 4) return 'JPEG';

  // JPEG: FF D8 FF
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
    return 'JPEG';
  }

  // PNG: 89 50 4E 47
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return 'PNG';
  }

  // GIF: 47 49 46 38
  if (bytes.length >= 6 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38) {
    return 'GIF';
  }

  // WEBP: RIFF header (bytes 0-3) followed by file size (bytes 4-7), then WEBP (bytes 8-11)
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'WEBP';
  }

  // BMP: 42 4D (ASCII 'BM')
  if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
    return 'BMP';
  }

  // Default to JPEG
  return 'JPEG';
}
