import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum for different event labels
enum EventLabel {
  /// Birthday event
  birthday,

  /// Anniversary event
  anniversary,

  /// Other type of event
  other,

  /// Custom label event
  custom,
  // iOS/macOS specific
  /// Work anniversary event (iOS/macOS specific)
  workAnniversary,
  // Android specific
  /// Newborn event (Android specific)
  newborn,

  /// Kids event (Android specific)
  kids,

  /// Parent anniversary event (Android specific)
  parentAnniversary,
}

/// Represents a contact event (birthday, anniversary, etc.)
@immutable
class ContactEvent extends Equatable {
  /// Creates a new [ContactEvent] with required month and day
  const ContactEvent({
    required this.month,
    required this.day,
    this.year,
    this.label = EventLabel.other,
    this.customLabel = '',
  });

  /// Creates a birthday event
  factory ContactEvent.birthday({
    required int month,
    required int day,
    int? year,
  }) {
    return ContactEvent(
      month: month,
      day: day,
      year: year,
      label: EventLabel.birthday,
    );
  }

  /// Creates an anniversary event
  factory ContactEvent.anniversary({
    required int month,
    required int day,
    int? year,
  }) {
    return ContactEvent(
      month: month,
      day: day,
      year: year,
      label: EventLabel.anniversary,
    );
  }

  /// Creates a custom event
  factory ContactEvent.custom({
    required int month,
    required int day,
    required String customLabel,
    int? year,
  }) {
    return ContactEvent(
      month: month,
      day: day,
      year: year,
      label: EventLabel.custom,
      customLabel: customLabel,
    );
  }

  /// Creates an event from a JSON map
  factory ContactEvent.fromJson(Map<String, dynamic> json) {
    return ContactEvent(
      month: (json['month'] as int?) ?? 1,
      day: (json['day'] as int?) ?? 1,
      year: json['year'] as int?,
      label: _stringToLabel(json['label'] as String?),
      customLabel: (json['customLabel'] as String?) ?? '',
    );
  }

  /// The month of the event (1-12)
  final int month;

  /// The day of the event (1-31)
  final int day;

  /// The year of the event (optional)
  final int? year;

  /// The label for this event
  final EventLabel label;

  /// Custom label if label is [EventLabel.custom]
  final String customLabel;

  /// Returns the display name for the event
  String get displayLabel {
    if (label == EventLabel.custom && customLabel.isNotEmpty) {
      return customLabel;
    }
    return _labelToString(label);
  }

  /// Returns true if this event has a year specified
  bool get hasYear => year != null;

  /// Returns a DateTime object for this event in the given year
  /// If no year is specified, uses the provided year or current year
  DateTime toDateTime([int? fallbackYear]) {
    final eventYear = year ?? fallbackYear ?? DateTime.now().year;
    return DateTime(eventYear, month, day);
  }

  /// Copy constructor
  ContactEvent copyWith({
    int? month,
    int? day,
    int? year,
    EventLabel? label,
    String? customLabel,
  }) {
    return ContactEvent(
      month: month ?? this.month,
      day: day ?? this.day,
      year: year ?? this.year,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
    );
  }

  /// Converts this event to a JSON map
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'month': month,
      'day': day,
      'label': _labelToString(label),
    };

    if (year != null) {
      json['year'] = year;
    }

    if (customLabel.isNotEmpty) {
      json['customLabel'] = customLabel;
    }

    return json;
  }

  /// Converts string to EventLabel
  static EventLabel _stringToLabel(String? labelString) {
    if (labelString == null || labelString.isEmpty) {
      return EventLabel.other;
    }

    switch (labelString.toLowerCase()) {
      case 'birthday':
        return EventLabel.birthday;
      case 'anniversary':
        return EventLabel.anniversary;
      case 'work anniversary':
      case 'workanniversary':
        return EventLabel.workAnniversary;
      case 'newborn':
        return EventLabel.newborn;
      case 'kids':
        return EventLabel.kids;
      case 'parent anniversary':
      case 'parentanniversary':
        return EventLabel.parentAnniversary;
      case 'custom':
        return EventLabel.custom;
      default:
        return EventLabel.other;
    }
  }

  /// Converts EventLabel to string
  static String _labelToString(EventLabel label) {
    switch (label) {
      case EventLabel.birthday:
        return 'Birthday';
      case EventLabel.anniversary:
        return 'Anniversary';
      case EventLabel.workAnniversary:
        return 'Work Anniversary';
      case EventLabel.newborn:
        return 'Newborn';
      case EventLabel.kids:
        return 'Kids';
      case EventLabel.parentAnniversary:
        return 'Parent Anniversary';
      case EventLabel.custom:
        return 'Custom';
      case EventLabel.other:
        return 'Other';
    }
  }

  @override
  List<Object?> get props => [month, day, year, label, customLabel];

  @override
  String toString() {
    final yearStr = year != null ? '/$year' : '';
    return '$displayLabel: $month/$day$yearStr';
  }
}
