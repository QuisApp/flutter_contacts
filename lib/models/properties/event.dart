import '../../utils/json_helpers.dart';
import '../labels/label.dart';
import '../labels/event_label.dart';
import 'property_metadata.dart';

/// Event property (e.g., birthdays, anniversaries).
///
/// iOS limits birthdays to one per contact; Android allows multiple events of any type.
class Event {
  /// Year. Null means the event recurs annually without a specific year.
  final int? year;

  /// Month (1-12).
  final int month;

  /// Day (1-31).
  final int day;

  /// Event label type.
  ///
  /// Defaults to [EventLabel.other].
  final Label<EventLabel> label;

  /// Property identity metadata (used internally for updates).
  final PropertyMetadata? metadata;

  const Event({
    this.year,
    required this.month,
    required this.day,
    Label<EventLabel>? label,
    this.metadata,
  }) : label = label ?? const Label(EventLabel.other);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'month': month, 'day': day};
    JsonHelpers.encode(json, 'year', year);
    json['label'] = label.toJson();
    JsonHelpers.encode(json, 'metadata', metadata, (m) => m.toJson());
    return json;
  }

  static Event fromJson(Map json) => Event(
    year: JsonHelpers.decode<int>(json['year']),
    month: json['month'] as int,
    day: json['day'] as int,
    label: Label.fromJson(
      json['label'] as Map,
      EventLabel.values,
      EventLabel.other,
    ),
    metadata: JsonHelpers.decode(json['metadata'], PropertyMetadata.fromJson),
  );

  @override
  String toString() => JsonHelpers.formatToString('Event', toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          year == other.year &&
          month == other.month &&
          day == other.day &&
          label == other.label);

  @override
  int get hashCode => Object.hash(year, month, day, label);

  Event copyWith({
    int? year,
    int? month,
    int? day,
    Label<EventLabel>? label,
    PropertyMetadata? metadata,
  }) => Event(
    year: year ?? this.year,
    month: month ?? this.month,
    day: day ?? this.day,
    label: label ?? this.label,
    metadata: metadata ?? this.metadata,
  );
}
