import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper para obtener el UID del usuario actual (o null si no está logueado)
  String? get _userId => _firebaseAuth.currentUser?.uid;

  @override
  Future<void> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Mapeo de errores comunes
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
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario creado.');
      }

      final serverTimestamp = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'bloodType': bloodType,
        'city': city,
        'ranking': 'Nuevo Donador', // Asignamos un ranking inicial
        'createdAt': serverTimestamp, // Fecha de creación
        'updatedAt': serverTimestamp, // Fecha de actualización (inicial)
        'deletedAt': null, // null para borrado lógico
        // --- COMENTARIO: Inicializamos las métricas para evitar valores hardcodeados ---
        'totalDonations': 0,
        'livesHelped': 0,
      });

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
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_userId == null) throw Exception('Usuario no autenticado.');

    try {
      final updateData = Map<String, dynamic>.from(data);

      // Los timestamps los controla el backend: evitamos sobrescribirlos manualmente.
      updateData.remove('updatedAt');
      updateData.remove('id');
      updateData.remove('createdAt');
      updateData.remove('deletedAt');
      updateData.remove('email');

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(_userId).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    if (_userId == null) throw Exception('Usuario no autenticado.');

    final userRef = _firestore.collection('users').doc(_userId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception('Perfil de usuario no encontrado.');
        }

        transaction.update(userRef, {
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      await logout();
    } catch (e) {
      throw Exception('Error al eliminar la cuenta: $e');
    }
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
