import 'package:equatable/equatable.dart';

/// Base class for all failures in the contacts bridge
abstract class Failure extends Equatable {
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
  const PermissionFailure(super.message, [super.code]);
}

/// Contact not found failure
class ContactNotFoundFailure extends Failure {
  const ContactNotFoundFailure(super.message, [super.code]);
}

/// Invalid contact data failure
class InvalidContactDataFailure extends Failure {
  const InvalidContactDataFailure(super.message, [super.code]);
}

/// Platform-specific operation failure
class PlatformFailure extends Failure {
  const PlatformFailure(super.message, [super.code]);
}

/// Network or external service failure
class ExternalServiceFailure extends Failure {
  const ExternalServiceFailure(super.message, [super.code]);
}

/// Unexpected error failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}
