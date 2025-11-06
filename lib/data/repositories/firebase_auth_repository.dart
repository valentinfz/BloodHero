import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      updateData.remove('id');
      updateData.remove('createdAt');
      updateData.remove('deletedAt');
      updateData.remove('email');

      await _firestore.collection('users').doc(_userId).update(updateData);
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    if (_userId == null) throw Exception('Usuario no autenticado.');

    final String randomPassword = _firestore.collection('users').doc().id;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'email': 'deleted_$_userId@bloodhero.com',
        'phone': '00000000',
        'name': 'Usuario Eliminado',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      try {
        await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(
          'disabled_$_userId@bloodhero.com',
        );
        await _firebaseAuth.currentUser?.updatePassword(randomPassword);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          if (kDebugMode) {
            print(
              'El borrado en Auth falló por "requires-recent-login", ' +
                  'pero el borrado lógico en Firestore fue exitoso. Procediendo a logout.',
            );
          }
        } else {
          if (kDebugMode) {
            print('Error al deshabilitar usuario en Auth: ${e.message}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error desconocido al deshabilitar Auth: $e');
        }
      }

      await logout();
    } catch (e) {
      throw Exception('Error al eliminar la cuenta: $e');
    }
  }
}
