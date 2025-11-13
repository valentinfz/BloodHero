// --- Métodos para Autenticación ---

abstract class AuthRepository {
  Future<void> login(String email, String password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  });

  Future<void> forgotPassword(String email);

  Future<void> logout();

  /// Cambia la contraseña del usuario actualmente autenticado.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
