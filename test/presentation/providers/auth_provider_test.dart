import 'package:bloodhero/domain/errors/auth_failure.dart';
import 'package:bloodhero/domain/repositories/auth_repository.dart';
import 'package:bloodhero/presentation/providers/auth_provider.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingAuthRepository implements AuthRepository {
  @override
  Future<void> forgotPassword(String email) async {
    throw AuthFailure(
      code: 'auth/user-not-found',
      message: 'No encontramos una cuenta asociada a $email.',
    );
  }

  @override
  Future<void> login(String email, String password) async {
    throw AuthFailure(
      code: 'auth/wrong-password',
      message: 'La contraseña no coincide con el registro.',
    );
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
    throw AuthFailure(
      code: 'auth/email-already-in-use',
      message: 'El email $email ya está registrado.',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw AuthFailure(
      code: 'auth/weak-password',
      message: 'La nueva contraseña es demasiado débil.',
    );
  }

  @override
  Future<void> deleteAccount() async {
    throw AuthFailure(
      code: 'auth/requires-recent-login',
      message: 'Necesitamos que inicies sesión nuevamente.',
    );
  }
}

void main() {
  group('AuthNotifier', () {
    test('propaga detalles de AuthFailure al fallar el login', () async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(_ThrowingAuthRepository()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('user@example.com', '123456');

      expect(container.read(authProvider), AuthState.error);
    });

  test('restablece el estado inicial al resetear', () async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(_ThrowingAuthRepository()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('user@example.com', '123456');
      notifier.resetState();

      expect(container.read(authProvider), AuthState.initial);
    });
  });
}
