/// A type-safe way to handle success and failure states
/// Used for operations that can fail, providing explicit error handling
sealed class Result<T, E> {
  const Result();

  /// Check if this result is a success
  bool get isSuccess => this is Success<T, E>;

  /// Check if this result is a failure
  bool get isFailure => this is Failure<T, E>;

  /// Get the success value (throws if failure)
  T get value {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    throw Exception('Cannot get value from a Failure result');
  }

  /// Get the success value or null
  T? get valueOrNull {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return null;
  }

  /// Get the error (throws if success)
  E get error {
    if (this is Failure<T, E>) {
      return (this as Failure<T, E>).error;
    }
    throw Exception('Cannot get error from a Success result');
  }

  /// Get the error or null
  E? get errorOrNull {
    if (this is Failure<T, E>) {
      return (this as Failure<T, E>).error;
    }
    return null;
  }

  /// Transform the success value
  Result<R, E> map<R>(R Function(T value) transform) {
    if (this is Success<T, E>) {
      return Success(transform((this as Success<T, E>).data));
    }
    return Failure((this as Failure<T, E>).error);
  }

  /// Transform the error value
  Result<T, F> mapError<F>(F Function(E error) transform) {
    if (this is Failure<T, E>) {
      return Failure(transform((this as Failure<T, E>).error));
    }
    return Success((this as Success<T, E>).data);
  }

  /// Execute a function based on success or failure
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    if (this is Success<T, E>) {
      return success((this as Success<T, E>).data);
    }
    return failure((this as Failure<T, E>).error);
  }

  /// Execute a function only if successful
  Result<T, E> onSuccess(void Function(T value) action) {
    if (this is Success<T, E>) {
      action((this as Success<T, E>).data);
    }
    return this;
  }

  /// Execute a function only if failed
  Result<T, E> onFailure(void Function(E error) action) {
    if (this is Failure<T, E>) {
      action((this as Failure<T, E>).error);
    }
    return this;
  }

  /// Get value or return a default
  T getOrElse(T defaultValue) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return defaultValue;
  }

  /// Get value or compute a default from the error
  T getOrElseWith(T Function(E error) defaultValue) {
    if (this is Success<T, E>) {
      return (this as Success<T, E>).data;
    }
    return defaultValue((this as Failure<T, E>).error);
  }
}

/// Represents a successful result
class Success<T, E> extends Result<T, E> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T, E> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed result
class Failure<T, E> extends Result<T, E> {
  @override
  final E error;

  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T, E> && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}
