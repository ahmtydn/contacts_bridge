import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum for different phone number labels
enum PhoneLabel {
  mobile,
  home,
  work,
  main,
  homeFax,
  workFax,
  pager,
  other,
  custom,
  // iOS specific
  iPhone,
  // Android specific
  assistant,
  callback,
  car,
  companyMain,
  isdn,
  radio,
  telex,
  ttyTdd,
  workMobile,
  workPager,
}

/// Represents a phone number
@immutable
class ContactPhone extends Equatable {
  const ContactPhone({
    required this.number,
    this.label = PhoneLabel.mobile,
    this.customLabel = '',
    this.isPrimary = false,
  });

  /// Creates a phone from a JSON map
  factory ContactPhone.fromJson(Map<String, dynamic> json) {
    return ContactPhone(
      number: (json['number'] as String?) ?? '',
      label: _stringToLabel(json['label'] as String?),
      customLabel: (json['customLabel'] as String?) ?? '',
      isPrimary: (json['isPrimary'] as bool?) ?? false,
    );
  }

  final String number;
  final PhoneLabel label;
  final String customLabel;
  final bool isPrimary;

  /// Returns the normalized phone number (digits only)
  String get normalizedNumber {
    return number.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Returns the display label for this phone number
  String get displayLabel {
    if (label == PhoneLabel.custom && customLabel.isNotEmpty) {
      return customLabel;
    }
    return _labelToString(label);
  }

  String _labelToString(PhoneLabel label) {
    switch (label) {
      case PhoneLabel.mobile:
        return 'Mobile';
      case PhoneLabel.home:
        return 'Home';
      case PhoneLabel.work:
        return 'Work';
      case PhoneLabel.main:
        return 'Main';
      case PhoneLabel.homeFax:
        return 'Home Fax';
      case PhoneLabel.workFax:
        return 'Work Fax';
      case PhoneLabel.pager:
        return 'Pager';
      case PhoneLabel.iPhone:
        return 'iPhone';
      case PhoneLabel.assistant:
        return 'Assistant';
      case PhoneLabel.callback:
        return 'Callback';
      case PhoneLabel.car:
        return 'Car';
      case PhoneLabel.companyMain:
        return 'Company Main';
      case PhoneLabel.isdn:
        return 'ISDN';
      case PhoneLabel.radio:
        return 'Radio';
      case PhoneLabel.telex:
        return 'Telex';
      case PhoneLabel.ttyTdd:
        return 'TTY/TDD';
      case PhoneLabel.workMobile:
        return 'Work Mobile';
      case PhoneLabel.workPager:
        return 'Work Pager';
      case PhoneLabel.other:
      case PhoneLabel.custom:
        return 'Other';
    }
  }

  /// Converts this phone to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'label': _labelToString(label),
      'customLabel': customLabel,
      'isPrimary': isPrimary,
    };
  }

  static PhoneLabel _stringToLabel(String? label) {
    if (label == null) return PhoneLabel.mobile;

    switch (label.toLowerCase()) {
      case 'mobile':
      case 'cell':
        return PhoneLabel.mobile;
      case 'home':
        return PhoneLabel.home;
      case 'work':
        return PhoneLabel.work;
      case 'main':
        return PhoneLabel.main;
      case 'homefax':
        return PhoneLabel.homeFax;
      case 'workfax':
        return PhoneLabel.workFax;
      case 'pager':
        return PhoneLabel.pager;
      case 'iphone':
        return PhoneLabel.iPhone;
      case 'assistant':
        return PhoneLabel.assistant;
      case 'callback':
        return PhoneLabel.callback;
      case 'car':
        return PhoneLabel.car;
      case 'companymain':
        return PhoneLabel.companyMain;
      case 'isdn':
        return PhoneLabel.isdn;
      case 'radio':
        return PhoneLabel.radio;
      case 'telex':
        return PhoneLabel.telex;
      case 'ttytdd':
        return PhoneLabel.ttyTdd;
      case 'workmobile':
        return PhoneLabel.workMobile;
      case 'workpager':
        return PhoneLabel.workPager;
      case 'custom':
        return PhoneLabel.custom;
      default:
        return PhoneLabel.other;
    }
  }

  ContactPhone copyWith({
    String? number,
    PhoneLabel? label,
    String? customLabel,
    bool? isPrimary,
  }) {
    return ContactPhone(
      number: number ?? this.number,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [number, label, customLabel, isPrimary];
}
