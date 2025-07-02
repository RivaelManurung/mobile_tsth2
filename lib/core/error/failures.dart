import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String message;

  const Failures(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failures {
  const ServerFailure(String message) : super(message);
}

class AuthFailure extends Failures {
  const AuthFailure(String message) : super(message);
}

class CacheFailure extends Failures {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failures {
  const NetworkFailure(String message) : super(message);
}