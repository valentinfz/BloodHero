import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloodhero/domain/entities/history_item_entity.dart';
import 'package:bloodhero/domain/entities/user_entity.dart';
import 'package:bloodhero/domain/repositories/user_repository.dart';
import 'package:bloodhero/domain/entities/appointment_entity.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<UserEntity> getUserProfile() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Perfil de usuario no encontrado.');
      }
      final data = doc.data()!;
      final displayName = _auth.currentUser?.displayName ?? data['name'];

      return UserEntity(
        name: displayName ?? 'Usuario',
        email: data['email'] ?? _auth.currentUser?.email ?? 'No email',
        phone: data['phone'] ?? 'No teléfono',
        city: data['city'] ?? 'No ciudad',
        bloodType: data['bloodType'] ?? 'No especificado',
        ranking: data['ranking'] ?? 'Donador',
      );
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: $e');
    }
  }

  @override
  Future<List<HistoryItemEntity>> getDonationHistory() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final date = timestamp?.toDate();
        final dateString = date != null
            ? '${date.day}/${date.month}/${date.year}'
            : 'Fecha inv.';
        final statusString = data['status'] as String? ?? 'scheduled';
        final status = AppointmentStatus.values.firstWhere(
          (e) => e.name == statusString,
          orElse: () => AppointmentStatus.scheduled,
        );
        final rawCenterId = data['centerId'] as String?;
        final centerId = rawCenterId ?? _slugifyCenterName(data['centerName']);
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

        return HistoryItemEntity(
          appointmentId: doc.id,
          centerId: centerId,
          date: dateString,
          center: data['centerName'] ?? 'Centro desconocido',
          type: data['donationType'] ?? 'No especificado',
          status: status,
          scheduledAt: date,
          updatedAt: updatedAt,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener historial de donaciones: $e');
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_userId == null) throw Exception('Usuario no autenticado.');

    try {
      final updateData = Map<String, dynamic>.from(data);
      final user = _auth.currentUser;

      updateData.remove('updatedAt');
      updateData.remove('id');
      updateData.remove('createdAt');
      updateData.remove('deletedAt');
      updateData.remove('email');

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      final nameValue = updateData['name'];
      if (user != null && nameValue is String && nameValue.trim().isNotEmpty) {
        await user.updateDisplayName(nameValue.trim());
      }

      await _firestore.collection('users').doc(_userId).update(updateData);
      await user?.reload();
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    if (_userId == null) throw Exception('Usuario no autenticado.');

    final userId = _userId!;
    final userRef = _firestore.collection('users').doc(userId);
    final user = _auth.currentUser;

    try {
      await _releaseUserBookedSlots(userId);

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

      if (user != null) {
        await user.delete();
      }

      // El logout lo maneja el AuthProvider después de llamar a esto
    } catch (e) {
      throw Exception('Error al eliminar la cuenta: $e');
    }
  }

  /// Helper privado movido de FirebaseAuthRepository
  Future<void> _releaseUserBookedSlots(String userId) async {
    final snapshot = await _firestore
        .collectionGroup('bookedSlots')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // --- Helpers ---
  String _slugifyCenterName(Object? rawCenter) {
    final value = (rawCenter ?? 'centro_desconocido').toString();
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
