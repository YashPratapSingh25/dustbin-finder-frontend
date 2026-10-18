import 'package:dustbin_finder/framework/core/network/network_exceptions.dart';

sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(NetworkExceptions error) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Failure<T>(error: final error) => failure(error),
    };
  }
}

final class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

final class Failure<T> extends ApiResult<T> {
  final NetworkExceptions error;

  const Failure(this.error);
}