import '../../domain/repositories/auth_repository.dart';

// Esta es la implementación "real" (pero con datos falsos) de nuestro contrato de autenticación.
class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login(String email, String password) async {
    // Simula una demora de red
    await Future.delayed(const Duration(seconds: 2));
    // Simula una validación simple
    if (email == 'test@test.com' && password == '123456') {
      return; // Login exitoso
    } else {
      throw Exception('Credenciales inválidas'); // Error de login
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  }) async {
    // Simula una demora de red
    await Future.delayed(const Duration(seconds: 2));
    // Aca se guardaria el usuario en la base de datos.
    // Para la simulación, simplemente asumimos que siempre funciona.
    return;
  }

  @override
  Future<void> forgotPassword(String email) async {
    // Simula una demora de red
    await Future.delayed(const Duration(seconds: 2));
    // Aca se llamaria al servicio de Firebase para enviar el email.
    // Para la simulación, asumimos que siempre funciona.
    return;
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserAccount() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) {
    throw UnimplementedError();
  }
}
