/// Custom exceptions for the contacts bridge
class ContactsException implements Exception {
  /// Creates a ContactsException with a message and optional error code
  const ContactsException(this.message, [this.code]);

  /// The error message

  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  @override
  String toString() =>
      'ContactsException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when permission is denied or insufficient
class PermissionException extends ContactsException {
  /// Creates a PermissionException with a message and optional error code
  const PermissionException(super.message, [super.code]);
}

/// Exception thrown when a requested contact is not found
class ContactNotFoundException extends ContactsException {
  /// Creates a ContactNotFoundException with a message and optional error code
  const ContactNotFoundException(super.message, [super.code]);
}

/// Exception thrown when contact data is invalid or corrupted
class InvalidContactException extends ContactsException {
  /// Creates an InvalidContactException with a message and optional error code
  const InvalidContactException(super.message, [super.code]);
}

/// Exception thrown when platform bridge communication fails
class PlatformBridgeException extends ContactsException {
  /// Creates a PlatformBridgeException with a message and optional error code
  const PlatformBridgeException(super.message, [super.code]);
}
