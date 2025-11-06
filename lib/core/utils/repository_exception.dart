class RepositoryException implements Exception {
  RepositoryException({
    required this.code,
    required this.message,
    this.cause,
  });

  final String code;
  final String message;
  final Object? cause;

  @override
  String toString() => 'RepositoryException($code): $message';
}
