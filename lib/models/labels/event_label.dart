/// Event label types (e.g., birthdays, anniversaries).
///
/// | Label       | Android | iOS |
/// |-------------|:-------:|:---:|
/// | anniversary | ✔       | ✔   |
/// | birthday    | ✔       | ✔   |
/// | other       | ✔       | ✔   |
/// | custom      | ✔       | ✔   |
///
/// iOS limits birthdays to one per contact; Android allows multiple events of any type.
enum EventLabel {
  anniversary,
  birthday,
  other,
  custom;

  bool get isSupported => true;
}
