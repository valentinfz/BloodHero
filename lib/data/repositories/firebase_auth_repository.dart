import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Añadimos la instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      throw Exception('Error de inicio de sesión: ${e.message}');
    } catch (e) {
      // Otros errores
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
      // Creamos el usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Obtenemos el UID del usuario recién creado
      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception('No se pudo obtener el ID del usuario creado.');
      }

      // ¡NUEVO! Guardamos los datos adicionales en Firestore
      // crea un documento en la colección 'users' con el ID del usuario
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'bloodType': bloodType,
        'city': city,
        'ranking': 'Nuevo Donador', // Asignamos un ranking inicial
        'createdAt':
            FieldValue.serverTimestamp(), // Guardamos la fecha de creación
      });

      // Opcional: Actualizar el nombre visible en Firebase Auth
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de registro: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al registrar: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      // Usamos el método de Firebase para enviar el email de recuperación
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error al enviar email: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al recuperar contraseña.');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
