import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definición del Estado de Autenticación:
// Representa los posibles estados de la UI durante el login/registro.
enum AuthState { initial, loading, success, error }

// El Notifier:
// Gestiona la lógica y el estado del formulario de autenticación.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial;
  }

  // Helper privado para ejecutar operaciones, manejar el estado y los errores
  Future<bool> _runAuthOperation(Future<void> Function() operation) async {
    state = AuthState.loading;
    try {
      await operation();
      state = AuthState.success;
      return true;
    } catch (e) {
      state = AuthState.error;
      return false;
    }
  }

  // Método para manejar el login
  Future<void> login(String email, String password) async {
    await _runAuthOperation(() {
      return ref.read(authRepositoryProvider).login(email, password);
    });
  }

  // Método para manejar el registro
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  }) async {
    await _runAuthOperation(() {
      return ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            bloodType: bloodType,
            city: city,
          );
    });
  }

  // Método para manejar la recuperación de contraseña
  Future<void> forgotPassword(String email) async {
    await _runAuthOperation(() {
      return ref.read(authRepositoryProvider).forgotPassword(email);
    });
  }

  // Método para cerrar sesión (ejemplo de cómo se agregaría)
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }

  // Método para resetear el estado (útil para salir de un estado de error)
  void resetState() {
    state = AuthState.initial;
  }
}

// El Provider principal que la UI consumirá
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
