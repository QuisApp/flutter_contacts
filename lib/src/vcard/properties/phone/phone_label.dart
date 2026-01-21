import '../../../../models/labels/phone_label.dart';
import '../../../../models/labels/label.dart';
import '../../core/version.dart';
import '../../utils/parsing/label_parsing.dart';

/// Returns whether phone label should be grouped (itemN. prefix).
/// v2.1 never groups; v3.0/v4.0 group non-standard labels.
/// CAR and ISDN are standard in v2.1/v3.0 but non-standard in v4.0.
bool shouldGroupPhone(PhoneLabel label, VCardVersion version) {
  if (version.isV21) return false;
  switch (label) {
    case PhoneLabel.mobile:
    case PhoneLabel.main:
    case PhoneLabel.home:
    case PhoneLabel.work:
    case PhoneLabel.companyMain:
    case PhoneLabel.homeFax:
    case PhoneLabel.workFax:
    case PhoneLabel.otherFax:
    case PhoneLabel.pager:
    case PhoneLabel.workPager:
      return false;
    case PhoneLabel.car:
    case PhoneLabel.isdn:
      return version.isV4; // Non-standard in v4.0
    default:
      return true;
  }
}

/// Returns TYPE values for phone label.
/// Non-standard: v2.1/v3.0 use fallback ['voice'], v4.0 uses [] (no TYPE when grouping).
List<String> getPhoneTypes(PhoneLabel label, VCardVersion version) {
  switch (label) {
    case PhoneLabel.mobile:
    case PhoneLabel.main:
      return ['voice'];
    case PhoneLabel.home:
      return ['home'];
    case PhoneLabel.work:
    case PhoneLabel.companyMain:
      return ['work'];
    case PhoneLabel.homeFax:
    case PhoneLabel.workFax:
    case PhoneLabel.otherFax:
      return ['fax'];
    case PhoneLabel.pager:
    case PhoneLabel.workPager:
      return ['pager'];
    case PhoneLabel.car:
      return version.isV4 ? [] : ['car'];
    case PhoneLabel.isdn:
      return version.isV4 ? [] : ['isdn'];
    default:
      return version.isV21OrV3 ? ['voice'] : [];
  }
}

/// Parses phone label from types and optional group label.
Label<PhoneLabel> parsePhoneLabel(List<String> types, String? groupLabel) {
  return parseLabel(
    types,
    groupLabel,
    PhoneLabel.values,
    PhoneLabel.custom,
    PhoneLabel.mobile,
    ignored: {'voice'},
    overrides: {'fax': PhoneLabel.homeFax},
  );
}
