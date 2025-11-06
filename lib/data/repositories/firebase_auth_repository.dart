import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/utils/repository_exception.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> login(String email, String password) async {
    try {
      // Usamos el método de Firebase para iniciar sesión
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Si no lanza excepción, el login fue exitoso
    } on FirebaseAuthException catch (e) {
      // Manejamos errores específicos de Firebase Auth
      // Podríamos mapear e.code a mensajes más amigables
      throw RepositoryException(
        code: 'auth/${e.code}',
        message: 'Error de inicio de sesión: ${e.message}',
        cause: e,
      );
    } catch (e) {
      // Otros errores
      throw RepositoryException(
        code: 'auth/unknown-login-error',
        message: 'Error desconocido al iniciar sesión.',
        cause: e,
      );
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
    try {
      // 1. Creamos el usuario en Firebase Auth
      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        throw RepositoryException(
          code: 'auth/null-user',
          message: 'No pudimos crear el usuario en Firebase Auth.',
        );
      }

      // 2. Guardamos los datos adicionales en Firestore para que existan en el perfil
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'bloodType': bloodType,
        'city': city,
        'ranking': 'Nuevo donador',
        'livesHelped': 0,
        'totalDonations': 0,
        'pointsEarned': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Opcional: Actualizar el nombre visible en Firebase Auth
      await user.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw RepositoryException(
        code: 'auth/${e.code}',
        message: 'Error de registro: ${e.message}',
        cause: e,
      );
    } on FirebaseException catch (e) {
      throw RepositoryException(
        code: 'firestore/${e.code}',
        message: 'Error guardando datos del usuario: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw RepositoryException(
        code: 'auth/unknown-register-error',
        message: 'Error desconocido al registrar.',
        cause: e,
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // Usamos el método de Firebase para enviar el email de recuperación
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw RepositoryException(
        code: 'auth/${e.code}',
        message: 'Error al enviar email: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw RepositoryException(
        code: 'auth/unknown-forgot-password-error',
        message: 'Error desconocido al recuperar contraseña.',
        cause: e,
      );
    }
  }

  // Podríamos añadir un método para cerrar sesión aquí también
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw RepositoryException(
        code: 'auth/not-authenticated',
        message: 'No hay un usuario autenticado.',
      );
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw RepositoryException(
        code: 'auth/${e.code}',
        message: 'No pudimos actualizar la contraseña: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw RepositoryException(
        code: 'auth/unknown-update-password-error',
        message: 'Ocurrió un error inesperado al actualizar la contraseña.',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw RepositoryException(
        code: 'auth/not-authenticated',
        message: 'No hay un usuario autenticado.',
      );
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw RepositoryException(
        code: 'auth/${e.code}',
        message: 'No pudimos eliminar la cuenta: ${e.message}',
        cause: e,
      );
    } catch (e) {
      throw RepositoryException(
        code: 'auth/unknown-delete-account-error',
        message: 'Ocurrió un error inesperado al eliminar la cuenta.',
        cause: e,
      );
    }
  }
}
