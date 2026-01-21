import 'dart:convert';
import 'dart:typed_data';
import '../../utils/json_helpers.dart';

/// Contact photo property.
///
/// Both thumbnail and full-size photos are optional and independent.
class Photo {
  /// Small, low-resolution photo (thumbnail, typically 96x96 or 150x150 pixels).
  final Uint8List? thumbnail;

  /// High-resolution photo (full-size, original resolution from device).
  final Uint8List? fullSize;

  const Photo({this.thumbnail, this.fullSize});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (thumbnail != null) {
      json['thumbnail'] = base64Encode(thumbnail!);
    }
    if (fullSize != null) {
      json['fullSize'] = base64Encode(fullSize!);
    }
    return json;
  }

  static Photo fromJson(Map json) {
    final thumbnailStr = JsonHelpers.decode<String>(json['thumbnail']);
    final fullSizeStr = JsonHelpers.decode<String>(json['fullSize']);
    return Photo(
      thumbnail: thumbnailStr != null ? base64Decode(thumbnailStr) : null,
      fullSize: fullSizeStr != null ? base64Decode(fullSizeStr) : null,
    );
  }

  @override
  String toString() => JsonHelpers.formatToString('Photo', {
    'thumbnail': thumbnail != null
        ? 'Uint8List(${thumbnail!.length} bytes)'
        : null,
    'fullSize': fullSize != null
        ? 'Uint8List(${fullSize!.length} bytes)'
        : null,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Photo) return false;
    // Optimization: Check hash first to avoid slow byte comparison
    if (other.hashCode != hashCode) return false;
    // Optimization: Check length
    if (thumbnail?.length != other.thumbnail?.length ||
        fullSize?.length != other.fullSize?.length) {
      return false;
    }
    // Fallback: Deep byte comparison
    return _listEquals(thumbnail, other.thumbnail) &&
        _listEquals(fullSize, other.fullSize);
  }

  @override
  int get hashCode {
    // Fast O(1) hashing: Length + First byte + Last byte + Middle byte
    int hashBytes(Uint8List? bytes) {
      if (bytes == null || bytes.isEmpty) return 0;
      final mid = bytes.length ~/ 2;
      return Object.hash(
        bytes.length,
        bytes[0],
        bytes[bytes.length - 1],
        bytes[mid],
      );
    }

    return Object.hash(hashBytes(thumbnail), hashBytes(fullSize));
  }

  Photo copyWith({Uint8List? thumbnail, Uint8List? fullSize}) => Photo(
    thumbnail: thumbnail ?? this.thumbnail,
    fullSize: fullSize ?? this.fullSize,
  );

  static bool _listEquals(Uint8List? a, Uint8List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
