import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthAction {
  login,
  register,
  forgotPassword,
  updateProfile,
  deleteAccount,
  changePassword,
}

abstract class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthInProgress extends AuthState {
  final AuthAction action;
  const AuthInProgress(this.action);
}

class AuthCompleted extends AuthState {
  final AuthAction action;
  const AuthCompleted(this.action);
}

class AuthFailure extends AuthState {
  final AuthAction action;
  final String message;
  const AuthFailure({required this.action, required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthFailure &&
        other.action == action &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(action, message);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthIdle();
  }

  Future<void> _runOperation({
    required AuthAction action,
    required Future<void> Function() operation,
  }) async {
    state = AuthInProgress(action);
    try {
      await operation();
      state = AuthCompleted(action);
    } catch (e) {
      state = AuthFailure(
        action: action,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> login(String email, String password) async {
    await _runOperation(
      action: AuthAction.login,
      operation: () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  }) async {
    await _runOperation(
      action: AuthAction.register,
      operation: () => ref
          .read(authRepositoryProvider)
          .register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            bloodType: bloodType,
            city: city,
          ),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _runOperation(
      action: AuthAction.forgotPassword,
      operation: () => ref.read(authRepositoryProvider).forgotPassword(email),
    );
  }

  Future<void> logout() async {
    // El logout no necesita 'runOperation'
    await ref.read(authRepositoryProvider).logout();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _runOperation(
      action: AuthAction.updateProfile,
      // CAMBIO: Apunta a userRepositoryProvider
      operation: () => ref.read(userRepositoryProvider).updateUserProfile(data),
    );
  }

  Future<void> deleteUserAccount() async {
    await _runOperation(
      action: AuthAction.deleteAccount,
      // CAMBIO: Apunta a userRepositoryProvider
      operation: () => ref.read(userRepositoryProvider).deleteUserAccount(),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _runOperation(
      action: AuthAction.changePassword,
      operation: () => ref
          .read(authRepositoryProvider)
          .changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
    );
  }

  void resetState() {
    state = const AuthIdle();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
