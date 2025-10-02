import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:contacts_bridge/src/domain/entities/contact_address.dart';
import 'package:contacts_bridge/src/domain/entities/contact_email.dart';
import 'package:contacts_bridge/src/domain/entities/contact_event.dart';
import 'package:contacts_bridge/src/domain/entities/contact_name.dart';
import 'package:contacts_bridge/src/domain/entities/contact_organization.dart';
import 'package:contacts_bridge/src/domain/entities/contact_phone.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents a complete contact with all its information
@immutable
class Contact extends Equatable {
  /// Creates a Contact with the given parameters
  const Contact({
    required this.id,
    required this.displayName,
    this.name = const ContactName(),
    this.phones = const [],
    this.emails = const [],
    this.addresses = const [],
    this.organizations = const [],
    this.notes = const [],
    this.websites = const [],
    this.socialProfiles = const [],
    this.events = const [],
    this.groups = const [],
    this.accounts = const [],
    this.thumbnail,
    this.photo,
    this.isStarred = false,
    this.linkedContactIds = const [],
    this.propertiesFetched = false,
    this.thumbnailFetched = false,
    this.photoFetched = false,
  });

  /// Creates a contact from a JSON map
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: (json['id'] as String?) ?? '',
      displayName: (json['displayName'] as String?) ?? '',
      name: json['name'] != null
          ? ContactName.fromJson(json['name'] as Map<String, dynamic>)
          : const ContactName(),
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map(
                (phone) => ContactPhone.fromJson(phone as Map<String, dynamic>),
              )
              .toList() ??
          [],
      emails:
          (json['emails'] as List<dynamic>?)
              ?.map(
                (email) => ContactEmail.fromJson(email as Map<String, dynamic>),
              )
              .toList() ??
          [],
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map(
                (address) =>
                    ContactAddress.fromJson(address as Map<String, dynamic>),
              )
              .toList() ??
          [],
      organizations:
          (json['organizations'] as List<dynamic>?)
              ?.map(
                (org) =>
                    ContactOrganization.fromJson(org as Map<String, dynamic>),
              )
              .toList() ??
          [],
      notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
      websites: (json['websites'] as List<dynamic>?)?.cast<String>() ?? [],
      socialProfiles:
          (json['socialProfiles'] as List<dynamic>?)?.cast<String>() ?? [],
      events:
          (json['events'] as List<dynamic>?)
              ?.map(
                (dynamic event) =>
                    ContactEvent.fromJson(event as Map<String, dynamic>),
              )
              .toList() ??
          [],
      groups: (json['groups'] as List<dynamic>?)?.cast<String>() ?? [],
      accounts: (json['accounts'] as List<dynamic>?)?.cast<String>() ?? [],
      thumbnail: _parseImageData(json['thumbnail']),
      photo: _parseImageData(json['photo']),
      isStarred: (json['isStarred'] as bool?) ?? false,
      linkedContactIds:
          (json['linkedContactIds'] as List<dynamic>?)?.cast<String>() ?? [],
      propertiesFetched: (json['propertiesFetched'] as bool?) ?? false,
      thumbnailFetched: (json['thumbnailFetched'] as bool?) ?? false,
      photoFetched: (json['photoFetched'] as bool?) ?? false,
    );
  }

  /// Unique identifier for the contact
  final String id;

  /// Display name of the contact
  final String displayName;

  /// Structured name information
  final ContactName name;

  /// List of phone numbers
  final List<ContactPhone> phones;

  /// List of email addresses
  final List<ContactEmail> emails;

  /// List of postal addresses
  final List<ContactAddress> addresses;

  /// List of organizations/jobs
  final List<ContactOrganization> organizations;

  /// List of notes
  final List<String> notes;

  /// List of website URLs
  final List<String> websites;

  /// List of social profiles
  final List<String> socialProfiles;

  /// List of events (birthdays, anniversaries, etc.)
  final List<ContactEvent> events;

  /// List of groups this contact belongs to
  final List<String> groups;

  /// List of accounts this contact is associated with
  final List<String> accounts;

  /// Low-resolution thumbnail image
  final Uint8List? thumbnail;

  /// High-resolution photo
  final Uint8List? photo;

  /// Whether the contact is starred/favorited
  final bool isStarred;

  /// List of linked contact IDs (for unified contacts)
  final List<String> linkedContactIds;

  /// Whether detailed properties were fetched
  final bool propertiesFetched;

  /// Whether thumbnail was fetched
  final bool thumbnailFetched;

  /// Whether photo was fetched
  final bool photoFetched;

  /// Returns the best available image (photo or thumbnail)
  Uint8List? get bestAvailableImage => photo ?? thumbnail;

  /// Returns the primary phone number if available
  ContactPhone? get primaryPhone {
    if (phones.isEmpty) return null;

    // First, try to find a phone marked as primary
    final primaryPhones = phones.where((phone) => phone.isPrimary);
    if (primaryPhones.isNotEmpty) return primaryPhones.first;

    // Otherwise, return the first phone
    return phones.first;
  }

  /// Returns the primary email address if available
  ContactEmail? get primaryEmail {
    if (emails.isEmpty) return null;

    // First, try to find an email marked as primary
    final primaryEmails = emails.where((email) => email.isPrimary);
    if (primaryEmails.isNotEmpty) return primaryEmails.first;

    // Otherwise, return the first email
    return emails.first;
  }

  /// Returns the birthday event if available
  ContactEvent? get birthday => events.firstWhereOrNull(
    (event) => event.label == EventLabel.birthday,
  );

  /// Returns all anniversary events
  List<ContactEvent> get anniversaries {
    return events
        .where(
          (event) =>
              event.label == EventLabel.anniversary ||
              event.label == EventLabel.workAnniversary ||
              event.label == EventLabel.parentAnniversary,
        )
        .toList();
  }

  /// Returns true if the contact has any contact information
  bool get hasContactInfo {
    return phones.isNotEmpty ||
        emails.isNotEmpty ||
        addresses.isNotEmpty ||
        websites.isNotEmpty;
  }

  /// Returns a brief summary of the contact for display
  String get summary {
    final parts = <String>[];

    if (name.displayName.isNotEmpty && name.displayName != displayName) {
      parts.add(name.displayName);
    }

    final primaryPhone = this.primaryPhone;
    if (primaryPhone != null) {
      parts.add(primaryPhone.number);
    }

    final primaryEmail = this.primaryEmail;
    if (primaryEmail != null) {
      parts.add(primaryEmail.address);
    }

    return parts.join(' • ');
  }

  /// Creates a copy of this contact with the given
  /// fields replaced with new values
  Contact copyWith({
    String? id,
    String? displayName,
    ContactName? name,
    List<ContactPhone>? phones,
    List<ContactEmail>? emails,
    List<ContactAddress>? addresses,
    List<ContactOrganization>? organizations,
    List<String>? notes,
    List<String>? websites,
    List<String>? socialProfiles,
    List<ContactEvent>? events,
    List<String>? groups,
    List<String>? accounts,
    Uint8List? thumbnail,
    Uint8List? photo,
    bool? isStarred,
    List<String>? linkedContactIds,
    bool? propertiesFetched,
    bool? thumbnailFetched,
    bool? photoFetched,
  }) {
    return Contact(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      addresses: addresses ?? this.addresses,
      organizations: organizations ?? this.organizations,
      notes: notes ?? this.notes,
      websites: websites ?? this.websites,
      socialProfiles: socialProfiles ?? this.socialProfiles,
      events: events ?? this.events,
      groups: groups ?? this.groups,
      accounts: accounts ?? this.accounts,
      thumbnail: thumbnail ?? this.thumbnail,
      photo: photo ?? this.photo,
      isStarred: isStarred ?? this.isStarred,
      linkedContactIds: linkedContactIds ?? this.linkedContactIds,
      propertiesFetched: propertiesFetched ?? this.propertiesFetched,
      thumbnailFetched: thumbnailFetched ?? this.thumbnailFetched,
      photoFetched: photoFetched ?? this.photoFetched,
    );
  }

  /// Converts this contact to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'name': name.toJson(),
      'phones': phones.map((phone) => phone.toJson()).toList(),
      'emails': emails.map((email) => email.toJson()).toList(),
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'organizations': organizations.map((org) => org.toJson()).toList(),
      'notes': notes,
      'websites': websites,
      'socialProfiles': socialProfiles,
      'events': events.map((event) => event.toJson()).toList(),
      'groups': groups,
      'accounts': accounts,
      'thumbnail': thumbnail,
      'photo': photo,
      'isStarred': isStarred,
      'linkedContactIds': linkedContactIds,
      'propertiesFetched': propertiesFetched,
      'thumbnailFetched': thumbnailFetched,
      'photoFetched': photoFetched,
    };
  }

  /// Helper method to parse image data
  static Uint8List? _parseImageData(dynamic data) {
    if (data == null) return null;

    if (data is Uint8List) {
      return data;
    } else if (data is List<int>) {
      return Uint8List.fromList(data);
    } else if (data is String) {
      try {
        return base64Decode(data);
      } on FormatException {
        return null;
      }
    }

    return null;
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    name,
    phones,
    emails,
    addresses,
    organizations,
    notes,
    websites,
    socialProfiles,
    events,
    groups,
    accounts,
    thumbnail,
    photo,
    isStarred,
    linkedContactIds,
    propertiesFetched,
    thumbnailFetched,
    photoFetched,
  ];
}
