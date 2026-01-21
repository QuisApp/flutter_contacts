import '../../../../models/properties/social_media.dart';
import '../../../../models/labels/social_media_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';
import '../../utils/encoding/encoding.dart';
import 'social_media_label.dart';

/// Parses social media property (X-SOCIALPROFILE).
SocialMedia parseSocialMedia(VCardProperty prop, [String? groupLabel]) {
  return parseProperty<SocialMedia, SocialMediaLabel>(
    prop,
    groupLabel,
    parseSocialMediaLabel,
    (
      String value,
      Label<SocialMediaLabel> label,
      Map<String, String?> params,
    ) => SocialMedia(username: unescapeValue(value), label: label),
  );
}
