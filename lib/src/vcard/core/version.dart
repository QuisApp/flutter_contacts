import '../../../models/vcard/vcard_version.dart';

export '../../../models/vcard/vcard_version.dart';

/// Extensions on VCardVersion for convenient version checks.
extension VCardVersionExtension on VCardVersion {
  bool get isV21 => this == VCardVersion.v21;
  bool get isV3 => this == VCardVersion.v3;
  bool get isV4 => this == VCardVersion.v4;
  bool get isV3OrV4 => this == VCardVersion.v3 || this == VCardVersion.v4;
  bool get isV21OrV3 => this == VCardVersion.v21 || this == VCardVersion.v3;
}
