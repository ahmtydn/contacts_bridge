import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents a name with all its components
@immutable
class ContactName extends Equatable {
  const ContactName({
    this.first = '',
    this.last = '',
    this.middle = '',
    this.prefix = '',
    this.suffix = '',
    this.nickname = '',
    this.phoneticFirst = '',
    this.phoneticLast = '',
    this.phoneticMiddle = '',
  });

  /// Creates a contact name from a JSON map
  factory ContactName.fromJson(Map<String, dynamic> json) {
    return ContactName(
      first: (json['first'] as String?) ?? '',
      last: (json['last'] as String?) ?? '',
      middle: (json['middle'] as String?) ?? '',
      prefix: (json['prefix'] as String?) ?? '',
      suffix: (json['suffix'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? '',
      phoneticFirst: (json['phoneticFirst'] as String?) ?? '',
      phoneticLast: (json['phoneticLast'] as String?) ?? '',
      phoneticMiddle: (json['phoneticMiddle'] as String?) ?? '',
    );
  }

  final String first;
  final String last;
  final String middle;
  final String prefix;
  final String suffix;
  final String nickname;
  final String phoneticFirst;
  final String phoneticLast;
  final String phoneticMiddle;

  /// Returns the full display name
  String get displayName {
    final parts = <String>[];
    if (prefix.isNotEmpty) parts.add(prefix);
    if (first.isNotEmpty) parts.add(first);
    if (middle.isNotEmpty) parts.add(middle);
    if (last.isNotEmpty) parts.add(last);
    if (suffix.isNotEmpty) parts.add(suffix);

    final fullName = parts.join(' ');
    return fullName.isNotEmpty ? fullName : nickname;
  }

  /// Returns the formal name (Last, First Middle)
  String get formalName {
    if (last.isEmpty && first.isEmpty) return displayName;

    final firstPart = [first, middle].where((s) => s.isNotEmpty).join(' ');
    if (last.isEmpty) return firstPart;
    if (firstPart.isEmpty) return last;

    return '$last, $firstPart';
  }

  ContactName copyWith({
    String? first,
    String? last,
    String? middle,
    String? prefix,
    String? suffix,
    String? nickname,
    String? phoneticFirst,
    String? phoneticLast,
    String? phoneticMiddle,
  }) {
    return ContactName(
      first: first ?? this.first,
      last: last ?? this.last,
      middle: middle ?? this.middle,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      nickname: nickname ?? this.nickname,
      phoneticFirst: phoneticFirst ?? this.phoneticFirst,
      phoneticLast: phoneticLast ?? this.phoneticLast,
      phoneticMiddle: phoneticMiddle ?? this.phoneticMiddle,
    );
  }

  /// Converts this contact name to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'last': last,
      'middle': middle,
      'prefix': prefix,
      'suffix': suffix,
      'nickname': nickname,
      'phoneticFirst': phoneticFirst,
      'phoneticLast': phoneticLast,
      'phoneticMiddle': phoneticMiddle,
    };
  }

  @override
  List<Object?> get props => [
    first,
    last,
    middle,
    prefix,
    suffix,
    nickname,
    phoneticFirst,
    phoneticLast,
    phoneticMiddle,
  ];
}
