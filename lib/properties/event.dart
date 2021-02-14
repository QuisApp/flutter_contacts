import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

/// An event, e.g. a birthday or anniversary
@JsonSerializable(disallowUnrecognizedKeys: true)
class Event {
  /// The event date.
  ///
  /// On Android this is stored as a free-form string, and therefore could fail
  /// to parse. In such cases we set the date to 1970-01-01.
  ///
  /// On iOS, this is stored in either `contact.birthday` (for birthday) or
  /// `contact.dates` (for other dates such as anniversary) as date components
  /// so parsing always succeeds. Additionally, dates can have no year
  /// associated with them. In such cases [noYear] will be true.
  @JsonKey(required: true, fromJson: _parseDate)
  DateTime date;

  /// The label or type of event it is. If `custom`, the free-form label can
  /// be found in [customLabel].
  @JsonKey(defaultValue: EventLabel.birthday)
  EventLabel label;

  /// If [customLabel] is [EventLabel.custom], free-form user-chosen label.
  @JsonKey(defaultValue: '')
  String customLabel;

  /// Whether the date has no year associated to it.
  @JsonKey(defaultValue: false)
  bool noYear;

  static DateTime _parseDate(String dateStr) => dateStr == null
      ? null
      : DateTime.tryParse(dateStr) ?? DateTime.fromMillisecondsSinceEpoch(0);

  Event(this.date,
      {this.label = EventLabel.birthday,
      this.customLabel = '',
      this.noYear = false});

  factory Event.fromJson(Map<String, dynamic> json) {
    var event = _$EventFromJson(json);
    if (Platform.isAndroid) {
      final parsedEvent =
          FlutterContacts.config.androidEventDateParser(json['date']);
      event.date = parsedEvent.date;
      event.noYear = parsedEvent.noYear;
    }
    return event;
  }

  Map<String, dynamic> toJson() {
    var json = _$EventToJson(this);
    if (Platform.isAndroid) {
      json['date'] =
          FlutterContacts.config.androidEventDateFormatter(date, noYear);
    }
    return json;
  }
}

/// Event labels
///
/// | Label       | Android | iOS |
/// |-------------|:-------:|:---:|
/// | anniversary | ✔       | ✔   |
/// | birthday    | ✔       | ✔   |
/// | other       | ✔       | ✔   |
/// | custom      | ✔       | ✔   |
enum EventLabel {
  anniversary,
  birthday,
  other,
  custom,
}
