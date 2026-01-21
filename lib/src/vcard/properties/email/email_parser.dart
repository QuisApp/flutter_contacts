import '../../../../models/properties/email.dart';
import '../../../../models/labels/email_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';
import '../../utils/encoding/encoding.dart';
import 'email_label.dart';

/// Parses EMAIL property into Email object.
Email parseEmail(VCardProperty prop, [String? groupLabel]) {
  return parseProperty<Email, EmailLabel>(
    prop,
    groupLabel,
    parseEmailLabel,
    (String value, Label<EmailLabel> label, Map<String, String?> params) =>
        Email(
          address: unescapeValue(value),
          isPrimary: isPrimaryProperty(params) ? true : null,
          label: label,
        ),
  );
}
