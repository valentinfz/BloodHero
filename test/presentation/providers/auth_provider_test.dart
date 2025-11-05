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
  Future<void> logout() async {}

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
  Future<void> deleteAccount({required String currentPassword}) async {
    throw AuthFailure(
      code: 'auth/requires-recent-login',
      message: 'Necesitamos que inicies sesión nuevamente.',
    );
  }

  @override
  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    throw AuthFailure(
      code: 'auth/invalid-email',
      message: 'El formato del nuevo email no es válido.',
    );
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw AuthFailure(
      code: 'auth/weak-password',
      message: 'La nueva contraseña es demasiado débil.',
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
      final feedback = notifier.feedback;
      expect(feedback, isNotNull);
      expect(feedback!.code, 'auth/wrong-password');
      expect(feedback.message, contains('contraseña'));
    });

    test('limpia feedback al resetear el estado', () async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(_ThrowingAuthRepository()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('user@example.com', '123456');
      notifier.resetState();

      expect(container.read(authProvider), AuthState.initial);
      expect(notifier.feedback, isNull);
    });
  });
}
