import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents an organization/job information
@immutable
class ContactOrganization extends Equatable {
  const ContactOrganization({
    this.company = '',
    this.title = '',
    this.department = '',
  });

  /// Creates an organization from a JSON map
  factory ContactOrganization.fromJson(Map<String, dynamic> json) {
    return ContactOrganization(
      company: (json['company'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      department: (json['department'] as String?) ?? '',
    );
  }

  final String company;
  final String title;
  final String department;

  /// Returns the formatted organization info
  String get formattedInfo {
    final parts = <String>[];

    if (title.isNotEmpty) parts.add(title);
    if (department.isNotEmpty) parts.add(department);
    if (company.isNotEmpty) parts.add(company);

    return parts.join(' at ');
  }

  /// Returns true if at least one field is not empty
  bool get isValid {
    return company.isNotEmpty || title.isNotEmpty || department.isNotEmpty;
  }

  /// Converts this organization to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'title': title,
      'department': department,
    };
  }

  ContactOrganization copyWith({
    String? company,
    String? title,
    String? department,
  }) {
    return ContactOrganization(
      company: company ?? this.company,
      title: title ?? this.title,
      department: department ?? this.department,
    );
  }

  @override
  List<Object?> get props => [company, title, department];
}
