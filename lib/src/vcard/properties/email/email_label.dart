import '../../../../models/labels/email_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/version.dart';
import '../../utils/parsing/label_parsing.dart';

/// Returns whether email label should be grouped (itemN. prefix).
/// v2.1 never groups; v3.0/v4.0 group non-standard labels.
bool shouldGroupEmail(EmailLabel label, VCardVersion version) {
  if (version.isV21) return false;
  switch (label) {
    case EmailLabel.home:
    case EmailLabel.work:
      return false;
    default:
      return true;
  }
}

/// Returns TYPE values for email label.
/// v2.1/v3.0 require 'internet' type for all emails.
/// Non-standard: v2.1/v3.0 use fallback ['internet'], v4.0 uses [] (no TYPE when grouping).
List<String> getEmailTypes(EmailLabel label, VCardVersion version) {
  switch (label) {
    case EmailLabel.home:
      return version.isV21OrV3 ? ['internet', 'home'] : ['home'];
    case EmailLabel.work:
      return version.isV21OrV3 ? ['internet', 'work'] : ['work'];
    default:
      return version.isV21OrV3 ? ['internet'] : [];
  }
}

/// Parses email label from types and optional group label.
Label<EmailLabel> parseEmailLabel(List<String> types, String? groupLabel) {
  return parseLabel(
    types,
    groupLabel,
    EmailLabel.values,
    EmailLabel.custom,
    EmailLabel.home,
    ignored: {'internet'},
  );
}
