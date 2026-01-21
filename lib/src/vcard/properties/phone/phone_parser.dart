import '../../../../models/properties/phone.dart';
import '../../../../models/labels/phone_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/property.dart';
import '../../utils/parsing/property_parsing.dart';
import '../../utils/encoding/encoding.dart';
import 'phone_label.dart';

/// Parses TEL property into Phone object.
///
/// Strips optional "tel:" prefix (vCard 4.0 uses tel: URI scheme).
Phone parsePhone(VCardProperty prop, [String? groupLabel]) {
  return parseProperty<Phone, PhoneLabel>(prop, groupLabel, parsePhoneLabel, (
    String value,
    Label<PhoneLabel> label,
    Map<String, String?> params,
  ) {
    final number = unescapeValue(value).replaceFirst(RegExp(r'^tel:'), '');
    return Phone(
      number: number,
      isPrimary: isPrimaryProperty(params) ? true : null,
      label: label,
    );
  });
}
