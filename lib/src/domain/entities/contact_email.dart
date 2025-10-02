import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum for different email labels
enum EmailLabel {
  /// Home email
  home,

  /// Work email
  work,

  /// School email
  school,

  /// Other email
  other,

  /// Custom email with custom label
  custom,

  // iOS specific
  /// iCloud email
  iCloud,
  // Android specific
  /// Mobile email
  mobile,
}

/// Represents an email address
@immutable
class ContactEmail extends Equatable {
  /// Creates a ContactEmail with the given parameters
  const ContactEmail({
    required this.address,
    this.label = EmailLabel.home,
    this.customLabel = '',
    this.isPrimary = false,
  });

  /// Creates an email from a JSON map
  factory ContactEmail.fromJson(Map<String, dynamic> json) {
    return ContactEmail(
      address: (json['address'] as String?) ?? '',
      label: _stringToLabel(json['label'] as String?),
      customLabel: (json['customLabel'] as String?) ?? '',
      isPrimary: (json['isPrimary'] as bool?) ?? false,
    );
  }

  /// The email address
  final String address;

  /// The label type for this email
  final EmailLabel label;

  /// Custom label text when label is EmailLabel.custom
  final String customLabel;

  /// Whether this is the primary email address
  final bool isPrimary;

  /// Returns true if the email address has a valid format
  bool get isValid {
    if (address.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(address);
  }

  /// Returns the display label for this email
  String get displayLabel {
    if (label == EmailLabel.custom && customLabel.isNotEmpty) {
      return customLabel;
    }
    return _labelToString(label);
  }

  String _labelToString(EmailLabel label) {
    switch (label) {
      case EmailLabel.home:
        return 'Home';
      case EmailLabel.work:
        return 'Work';
      case EmailLabel.school:
        return 'School';
      case EmailLabel.iCloud:
        return 'iCloud';
      case EmailLabel.mobile:
        return 'Mobile';
      case EmailLabel.other:
      case EmailLabel.custom:
        return 'Other';
    }
  }

  /// Converts this email to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'label': _labelToString(label),
      'customLabel': customLabel,
      'isPrimary': isPrimary,
    };
  }

  static EmailLabel _stringToLabel(String? label) {
    if (label == null) return EmailLabel.home;

    switch (label.toLowerCase()) {
      case 'home':
        return EmailLabel.home;
      case 'work':
        return EmailLabel.work;
      case 'school':
        return EmailLabel.school;
      case 'icloud':
        return EmailLabel.iCloud;
      case 'mobile':
        return EmailLabel.mobile;
      case 'custom':
        return EmailLabel.custom;
      default:
        return EmailLabel.other;
    }
  }

  /// Creates a copy of this email with the
  /// given fields replaced with new values
  ContactEmail copyWith({
    String? address,
    EmailLabel? label,
    String? customLabel,
    bool? isPrimary,
  }) {
    return ContactEmail(
      address: address ?? this.address,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [address, label, customLabel, isPrimary];
}
