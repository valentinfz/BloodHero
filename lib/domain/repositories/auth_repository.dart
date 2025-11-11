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

  /// Actualiza los datos básicos del usuario.
  ///
  /// Implementaciones deben:
  /// - Ignorar/tomar como no válidos los campos `createdAt` y `deletedAt`.
  /// - Registrar siempre un nuevo `updatedAt` con `FieldValue.serverTimestamp()`.
  Future<void> updateUserProfile(Map<String, dynamic> data);

  /// Marca la cuenta como eliminada sin borrar el documento en Firestore.
  ///
  /// Implementaciones deben actualizar `deletedAt` con
  /// `FieldValue.serverTimestamp()` (si estaba en `null`) y registrar un nuevo
  /// `updatedAt`. El documento no debe eliminarse físicamente.
  Future<void> deleteUserAccount();

  /// Cambia la contraseña del usuario actualmente autenticado.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
