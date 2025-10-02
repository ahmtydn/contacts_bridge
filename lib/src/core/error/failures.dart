import 'package:equatable/equatable.dart';

/// Base class for all failures in the contacts bridge
abstract class Failure extends Equatable {
  /// Creates a Failure with a message and optional error code
  const Failure(this.message, [this.code]);

  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Permission-related failures
class PermissionFailure extends Failure {
  /// Creates a PermissionFailure with a message and optional error code
  const PermissionFailure(super.message, [super.code]);
}

/// Contact not found failure
class ContactNotFoundFailure extends Failure {
  /// Creates a ContactNotFoundFailure with a message and optional error code
  const ContactNotFoundFailure(super.message, [super.code]);
}

/// Invalid contact data failure
class InvalidContactDataFailure extends Failure {
  /// Creates an InvalidContactDataFailure with a
  /// message and optional error code
  const InvalidContactDataFailure(super.message, [super.code]);
}

/// Platform-specific operation failure
class PlatformFailure extends Failure {
  /// Creates a PlatformFailure with a message and optional error code
  const PlatformFailure(super.message, [super.code]);
}

/// Network or external service failure
class ExternalServiceFailure extends Failure {
  /// Creates an ExternalServiceFailure with a message and optional error code
  const ExternalServiceFailure(super.message, [super.code]);
}

/// Unexpected error failure
class UnexpectedFailure extends Failure {
  /// Creates an UnexpectedFailure with a message and optional error code
  const UnexpectedFailure(super.message, [super.code]);
}
