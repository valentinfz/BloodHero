import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
      // 1. Creamos el usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. (Importante) Guardamos los datos adicionales (nombre, teléfono, etc.)
      //    en Firestore. Esto lo haremos cuando implementemos FirebaseCentersRepository.
      //    Por ahora, solo creamos el usuario en Auth.
      //    await saveUserDataToFirestore(userCredential.user!.uid, name, phone, bloodType, city);

      // Opcional: Actualizar el nombre visible en Firebase Auth
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de registro: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al registrar.');
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

  // Podríamos añadir un método para cerrar sesión aquí también
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
