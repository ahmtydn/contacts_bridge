/// Custom exceptions for the contacts bridge
class ContactsException implements Exception {
  const ContactsException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'ContactsException: $message${code != null ? ' (Code: $code)' : ''}';
}

class PermissionException extends ContactsException {
  const PermissionException(super.message, [super.code]);
}

class ContactNotFoundException extends ContactsException {
  const ContactNotFoundException(super.message, [super.code]);
}

class InvalidContactException extends ContactsException {
  const InvalidContactException(super.message, [super.code]);
}

class PlatformBridgeException extends ContactsException {
  const PlatformBridgeException(super.message, [super.code]);
}
