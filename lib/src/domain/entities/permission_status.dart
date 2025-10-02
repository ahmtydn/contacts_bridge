/// Represents the current permission status for accessing contacts
enum PermissionStatus {
  /// The user hasn't been asked for permission yet
  notDetermined('not_determined'),

  /// The user has denied permission
  denied('denied'),

  /// The user has granted full access to contacts
  authorized('authorized'),

  /// The user has granted limited access to contacts (iOS 14+)
  limited('limited'),

  /// The app is restricted from accessing contacts (e.g., by parental controls)
  restricted('restricted');

  final String value;
  const PermissionStatus(this.value);

  @override
  String toString() => value;

  String get description {
    switch (this) {
      case PermissionStatus.notDetermined:
        return 'Permission not requested';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.authorized:
        return 'Full access granted';
      case PermissionStatus.limited:
        return 'Limited access granted';
      case PermissionStatus.restricted:
        return 'Access restricted';
    }
  }

  /// Returns true if the permission allows reading contacts
  bool get canRead =>
      this == PermissionStatus.authorized || this == PermissionStatus.limited;

  /// Returns true if the permission allows writing contacts
  bool get canWrite => this == PermissionStatus.authorized;

  /// Returns true if permission was explicitly denied by the user
  bool get isDenied => this == PermissionStatus.denied;

  /// Returns true if permission is restricted by the system
  bool get isRestricted => this == PermissionStatus.restricted;
}
