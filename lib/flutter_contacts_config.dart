import 'package:flutter_contacts/properties/event.dart';

class FlutterContactsConfig {
  // No need for fancier validation like months with only 30 days or leap years
  // since DateTime already takes care of it (e.g. 2001/11/31 -> 2011/12/01 and
  // 2019/02/29 -> 2019/03/01)
  static final _dateRegexp =
      RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)$');
  static final _noYearDateRegexp =
      RegExp(r'^--(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|30|31)$');

  /// Function to use when serializing event dates on Android.
  ///
  /// More context: unlike on iOS where the event date is encoded as a datetime
  /// in the contacts database, on Android it is encoded as a free-form string,
  /// with no specific format specified, meaning the event saved by one app may
  /// not be readable by another app. See also
  /// https://github.com/QuisApp/flutter_contacts/issues/2
  ///
  /// The following default mimics the behavior of the default Android App
  /// version 3.38.1 where dates are of the form YYYY-MM-DD or --MM-DD for dates
  /// with no year.
  String Function(DateTime, bool) androidEventDateFormatter =
      (DateTime date, bool noYear) =>
          '${noYear ? '-' : date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

  /// Function to use when unserializing event dates on Android.
  ///
  /// The following default mimics the behavior of the default Android App
  /// version 3.38.1 where dates are of the form YYYY-MM-DD or --MM-DD for dates
  /// with no year.
  Event Function(String) androidEventDateParser = (date) {
    if (_dateRegexp.hasMatch(date)) {
      return Event(DateTime(int.parse(date.substring(0, 4)),
          int.parse(date.substring(5, 7)), int.parse(date.substring(8, 10))));
    }
    if (_noYearDateRegexp.hasMatch(date)) {
      return Event(
          DateTime(1970, int.parse(date.substring(2, 4)),
              int.parse(date.substring(5, 7))),
          noYear: true);
    }
    return Event(
        DateTime.tryParse(date) ?? DateTime.fromMillisecondsSinceEpoch(0));
  };
}
