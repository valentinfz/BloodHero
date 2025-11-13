import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw Exception('Email o contraseña incorrectos.');
      } else if (e.code == 'invalid-email') {
        throw Exception('El formato del email es incorrecto.');
      }
      throw Exception('Error de inicio de sesión: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al iniciar sesión.');
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
      // 1. Crear el usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario creado.');
      }

      // 2. Guardar los datos del usuario en Firestore
      // (Esta lógica fue movida desde el antiguo firebase_centers_repository)
      await _saveUserDataToFirestore(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        bloodType: bloodType,
        city: city,
      );

      // 3. (Opcional) Actualizar el display name en Auth
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El email ya se encuentra registrado.');
      } else if (e.code == 'weak-password') {
        throw Exception(
          'La contraseña es muy débil (debe tener 6 caracteres).',
        );
      }
      throw Exception('Error de registro: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al registrar: $e');
    }
  }

  /// Método privado para guardar datos en Firestore durante el registro
  Future<void> _saveUserDataToFirestore({
    required String userId,
    required String name,
    required String phone,
    required String bloodType,
    required String city,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'bloodType': bloodType,
        'city': city,
        'ranking': 'Nuevo Donador', // Ranking inicial
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
        'totalDonations': 0,
        'livesHelped': 0,
      });
    } catch (e) {
      throw Exception('Error al guardar datos del usuario en Firestore: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe un usuario registrado con ese email.');
      }
      throw Exception('Error al enviar email: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al recuperar contraseña.');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Usuario no autenticado.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('La contraseña actual no es correcta.');
      }
      if (e.code == 'weak-password') {
        throw Exception('La nueva contraseña es muy débil.');
      }
      throw Exception('No se pudo actualizar la contraseña: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al cambiar la contraseña.');
    }
  }
}
