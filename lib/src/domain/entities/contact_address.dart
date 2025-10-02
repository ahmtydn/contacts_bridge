import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum for different address labels
enum AddressLabel {
  /// Home address
  home,

  /// Work address
  work,

  /// School address
  school,

  /// Other address
  other,

  /// Custom address with custom label
  custom,
}

/// Represents a postal address
@immutable
class ContactAddress extends Equatable {
  /// Creates a ContactAddress with the given parameters
  const ContactAddress({
    this.street = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
    this.isoCountry = '',
    this.subAdministrativeArea = '',
    this.subLocality = '',
    this.label = AddressLabel.home,
    this.customLabel = '',
  });

  /// Creates an address from a JSON map
  factory ContactAddress.fromJson(Map<String, dynamic> json) {
    return ContactAddress(
      street: (json['street'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      postalCode: (json['postalCode'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      isoCountry: (json['isoCountry'] as String?) ?? '',
      subAdministrativeArea: (json['subAdministrativeArea'] as String?) ?? '',
      subLocality: (json['subLocality'] as String?) ?? '',
      label: _stringToLabel(json['label'] as String?),
      customLabel: (json['customLabel'] as String?) ?? '',
    );
  }

  /// The street address
  final String street;

  /// The city
  final String city;

  /// The state or province
  final String state;

  /// The postal code
  final String postalCode;

  /// The country
  final String country;

  /// The ISO country code
  final String isoCountry;

  /// The sub administrative area
  final String subAdministrativeArea;

  /// The sub locality
  final String subLocality;

  /// The address label type
  final AddressLabel label;

  /// Custom label text when label is AddressLabel.custom
  final String customLabel;

  /// Returns the formatted address as a single string
  String get formattedAddress {
    final parts = <String>[];

    if (street.isNotEmpty) parts.add(street);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    if (country.isNotEmpty) parts.add(country);

    return parts.join(', ');
  }

  /// Returns the display label for this address
  String get displayLabel {
    if (label == AddressLabel.custom && customLabel.isNotEmpty) {
      return customLabel;
    }
    return _labelToString(label);
  }

  String _labelToString(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return 'Home';
      case AddressLabel.work:
        return 'Work';
      case AddressLabel.school:
        return 'School';
      case AddressLabel.other:
      case AddressLabel.custom:
        return 'Other';
    }
  }

  /// Returns true if the address has at least one non-empty field
  bool get isValid {
    return street.isNotEmpty ||
        city.isNotEmpty ||
        state.isNotEmpty ||
        postalCode.isNotEmpty ||
        country.isNotEmpty;
  }

  /// Converts this address to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isoCountry': isoCountry,
      'subAdministrativeArea': subAdministrativeArea,
      'subLocality': subLocality,
      'label': _labelToString(label),
      'customLabel': customLabel,
    };
  }

  static AddressLabel _stringToLabel(String? label) {
    if (label == null) return AddressLabel.home;

    switch (label.toLowerCase()) {
      case 'home':
        return AddressLabel.home;
      case 'work':
        return AddressLabel.work;
      case 'school':
        return AddressLabel.school;
      case 'custom':
        return AddressLabel.custom;
      default:
        return AddressLabel.other;
    }
  }

  /// Creates a copy of this contact address with the
  /// given fields replaced with new values
  ContactAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? isoCountry,
    String? subAdministrativeArea,
    String? subLocality,
    AddressLabel? label,
    String? customLabel,
  }) {
    return ContactAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isoCountry: isoCountry ?? this.isoCountry,
      subAdministrativeArea:
          subAdministrativeArea ?? this.subAdministrativeArea,
      subLocality: subLocality ?? this.subLocality,
      label: label ?? this.label,
      customLabel: customLabel ?? this.customLabel,
    );
  }

  @override
  List<Object?> get props => [
    street,
    city,
    state,
    postalCode,
    country,
    isoCountry,
    subAdministrativeArea,
    subLocality,
    label,
    customLabel,
  ];
}
