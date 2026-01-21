import '../../../../models/labels/social_media_label.dart';
import '../../../../models/labels/label.dart';
import '../../utils/parsing/label_parsing.dart';

/// Parses social media label from types and optional group label.
///
/// X-SOCIALPROFILE has no standard TYPE values, so it only uses groupLabel.
Label<SocialMediaLabel> parseSocialMediaLabel(
  List<String> types,
  String? groupLabel,
) {
  return parseLabel(
    types,
    groupLabel,
    SocialMediaLabel.values,
    SocialMediaLabel.custom,
    SocialMediaLabel.other,
  );
}
