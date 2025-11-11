import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

// El Notifier:
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthInitial();
  }

  // Helper para operaciones que SÍ inician sesión (login, register)
  Future<bool> _runLoginOperation(Future<void> Function() operation) async {
    state = const AuthLoading();
    try {
      await operation();
      state = const AuthSuccess();
      return true;
    } catch (e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  // Helper para operaciones que NO inician sesión (forgot password, update, delete)
  Future<bool> _runSideOperation(Future<void> Function() operation) async {
    state = const AuthLoading();
    try {
      await operation();
      state = const AuthInitial();
      return true;
    } catch (e) {
      state = AuthError(e.toString().replaceFirst("Exception: ", ""));
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    await _runLoginOperation(() {
      return ref.read(authRepositoryProvider).login(email, password);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  }) async {
    await _runLoginOperation(() {
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

  Future<void> forgotPassword(String email) async {
    await _runSideOperation(() {
      return ref.read(authRepositoryProvider).forgotPassword(email);
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    // NOTA: Podrías querer que el logout también cambie el estado
    // state = const AuthInitial();
  }

  /// Actualiza el perfil de usuario (ej. desde EditProfileScreen)
  /// Usa _runSideOperation para mostrar feedback (loading/error) sin desloguear.
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _runSideOperation(() {
      return ref.read(authRepositoryProvider).updateUserProfile(data);
    });
  }

  /// Borra la cuenta del usuario (ej. desde SecurityScreen)
  /// Usa _runSideOperation para mostrar feedback y luego desloguear.
  Future<void> deleteUserAccount() async {
    await _runSideOperation(() {
      return ref.read(authRepositoryProvider).deleteUserAccount();
    });
    // Adicionalmente, reseteamos el estado a Initial por si acaso.
    state = const AuthInitial();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _runSideOperation(() {
      return ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
    });
  }

  void resetState() {
    state = const AuthInitial();
  }
}

// El Provider principal que la UI consumirá
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
