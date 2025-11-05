// Representa un error de autenticación proveniente de FirebaseAuth u otras fuentes.
class AuthFailure implements Exception {
  AuthFailure({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'AuthFailure(code: $code, message: $message)';
}
