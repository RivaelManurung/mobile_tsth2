import 'package:inventory_tsth2/core/error/failures.dart';

class MapFailureToMessage {
  static String map(Failures failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case AuthFailure:
        return (failure as AuthFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case CacheFailure:
        return 'Cache Error: ${(failure as CacheFailure).message}';
      default:
        return 'Unexpected Error';
    }
  }
}