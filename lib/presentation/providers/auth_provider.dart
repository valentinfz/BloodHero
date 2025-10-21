import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fake_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Cuando conectemos Firebase, solo cambiar esta línea.
  return FakeAuthRepository();
});

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

  // Método para manejar el login
  Future<void> login(String email, String password) async {
    state = AuthState.loading; // Pone la UI en estado de carga
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.login(email, password);
      state =
          AuthState.success; // Si todo va bien, pone la UI en estado de éxito
    } catch (e) {
      state = AuthState.error; // Si hay un error, lo notifica a la UI
    }
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
    state = AuthState.loading;
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        bloodType: bloodType,
        city: city,
      );
      state = AuthState.success;
    } catch (e) {
      state = AuthState.error;
    }
  }

  // Método para manejar la recuperación de contraseña
  Future<void> forgotPassword(String email) async {
    state = AuthState.loading;
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.forgotPassword(email);
      state = AuthState.success;
    } catch (e) {
      state = AuthState.error;
    }
  }

  // Método para resetear el estado (útil para salir de un estado de error)
  void resetState() {
    state = AuthState.initial;
  }
}

// 4. El Provider principal que la UI consumirá
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
