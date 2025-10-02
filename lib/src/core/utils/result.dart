import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:equatable/equatable.dart';

/// A generic class for handling results that can be either success or failure
abstract class Result<T> extends Equatable {
  const Result();

  /// Returns true if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is a failure
  bool get isFailure => this is Failed<T>;

  /// Returns the success value if successful, null otherwise
  T? get value => isSuccess ? (this as Success<T>).data : null;

  /// Returns the failure if failed, null otherwise
  Failure? get failure => isFailure ? (this as Failed<T>).failure : null;

  /// Transforms the success value using the provided function
  Result<R> map<R>(R Function(T) transform) {
    if (isSuccess) {
      try {
        return Success(transform(value as T));
      } catch (e) {
        return Failed(UnexpectedFailure('Transform failed: $e'));
      }
    }
    return Failed(failure!);
  }

  /// Executes a function if the result is successful
  Result<T> onSuccess(void Function(T) action) {
    if (isSuccess) {
      action(value as T);
    }
    return this;
  }

  /// Executes a function if the result is a failure
  Result<T> onFailure(void Function(Failure) action) {
    if (isFailure) {
      action(failure!);
    }
    return this;
  }

  @override
  List<Object?> get props => [];
}

/// Represents a successful result
class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

/// Represents a failed result
class Failed<T> extends Result<T> {
  const Failed(this.failure);

  @override
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Extension methods for easier result handling
extension ResultExtensions<T> on Result<T> {
  /// Returns the value if successful, throws the failure message otherwise
  T unwrap() {
    if (isSuccess) {
      return value as T;
    }
    throw Exception(failure!.message);
  }

  /// Returns the value if successful, the provided default value otherwise
  T unwrapOr(T defaultValue) {
    return isSuccess ? value as T : defaultValue;
  }

  /// Returns the value if successful,
  /// the result of the provided function otherwise
  T unwrapOrElse(T Function(Failure) defaultValue) {
    return isSuccess ? value as T : defaultValue(failure!);
  }
}
