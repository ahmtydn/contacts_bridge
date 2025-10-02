import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/repositories/contacts_repository.dart';

/// Base class for all use cases
/// This ensures consistent structure and follows the
/// Single Responsibility Principle
abstract class UseCase<T, Params> {
  /// Creates a UseCase with the given repository
  const UseCase(this.repository);

  /// The repository used by this use case

  final ContactsRepository repository;

  /// Executes the use case with the given parameters
  Future<Result<T>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<T> {
  /// Creates a NoParamsUseCase with the given repository
  const NoParamsUseCase(this.repository);

  /// The repository used by this use case

  final ContactsRepository repository;

  /// Executes the use case
  Future<Result<T>> call();
}
