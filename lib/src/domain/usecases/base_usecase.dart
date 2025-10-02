import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/repositories/contacts_repository.dart';

/// Base class for all use cases
/// This ensures consistent structure and follows the
/// Single Responsibility Principle
abstract class UseCase<Type, Params> {
  const UseCase(this.repository);

  final ContactsRepository repository;

  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  const NoParamsUseCase(this.repository);

  final ContactsRepository repository;

  Future<Result<Type>> call();
}
