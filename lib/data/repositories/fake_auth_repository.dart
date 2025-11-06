import '../../core/utils/repository_exception.dart';
import '../../domain/repositories/auth_repository.dart';

// Esta es la implementación "real" (pero con datos falsos) de nuestro contrato de autenticación.
class FakeAuthRepository implements AuthRepository {
  String _storedEmail = 'test@test.com';
  String _storedPassword = '123456';
  bool _activeAccount = true;

  @override
  Future<void> login(String email, String password) async {
    // Simula una demora de red
    await Future.delayed(const Duration(seconds: 2));
    // Simula una validación simple
    if (_activeAccount && email == _storedEmail && password == _storedPassword) {
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
    _storedEmail = email;
    _storedPassword = password;
    _activeAccount = true;
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
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    if (newPassword.length < 6) {
      throw RepositoryException(
        code: 'auth/weak-password',
        message: 'La contraseña debe tener al menos 6 caracteres.',
      );
    }
    _storedPassword = newPassword;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
    _activeAccount = false;
  }
}
