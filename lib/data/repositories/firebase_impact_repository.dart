import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:bloodhero/domain/entities/achievement_detail_entity.dart';
import 'package:bloodhero/domain/entities/achievement_entity.dart';
import 'package:bloodhero/domain/entities/user_impact_entity.dart';
import 'package:bloodhero/domain/repositories/impact_repository.dart';

class FirebaseImpactRepository implements ImpactRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<UserImpactEntity> getUserImpactStats() async {
    final userId = _userId;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('Perfil de usuario no encontrado para estadísticas.');
      }
      final data = doc.data()!;

      final livesHelped = (data['livesHelped'] as num?)?.toInt() ?? 0;
      final totalDonations = (data['totalDonations'] as num?)?.toInt() ?? 0;
      final ranking = data['ranking'] as String? ?? 'Donador';

      return UserImpactEntity(
        livesHelped: livesHelped,
        totalDonations: totalDonations,
        ranking: ranking,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas de impacto: $e');
    }
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    final userId = _userId;
    if (userId == null) {
      return [];
    }

    try {
      final unlockedSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('unlockedAchievements')
          .orderBy('unlockedAt', descending: true)
          .get();

      if (unlockedSnapshot.docs.isEmpty) {
        return [];
      }

      final unlockedDocs = unlockedSnapshot.docs;
      final unlockedIds = unlockedDocs.map((doc) => doc.id).toList();
      final definitionDocs = await _fetchAchievementDefinitions(unlockedIds);
      final definitionsById = {
        for (final doc in definitionDocs) doc.id: doc.data(),
      };

      final achievements = unlockedDocs.map((doc) {
        final data = doc.data();
        final unlockedAtTimestamp = data['unlockedAt'] as Timestamp?;
        final definition = definitionsById[doc.id];
        final title = definition?['title'] ?? data['title'] ?? doc.id;
        final description =
            definition?['description'] ?? data['description'] ?? '';
        final iconName =
            (definition?['iconName'] as String?) ??
            (data['iconName'] as String?);

        return AchievementEntity(
          title: title,
          description: description,
          iconName: iconName,
          unlockedAt: unlockedAtTimestamp?.toDate(),
        );
      }).toList();

      achievements.sort(
        (a, b) => (b.unlockedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.unlockedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
      return achievements;
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  @override
  Future<AchievementDetailEntity> getAchievementDetails(String title) async {
    try {
      QueryDocumentSnapshot<Map<String, dynamic>>? doc;

      final catalogSnapshot = await _firestore
          .collection(
            'achievementsCatalog',
          ) // Intenta buscar en el catálogo primero
          .where('title', isEqualTo: title)
          .limit(1)
          .get();
      if (catalogSnapshot.docs.isNotEmpty) {
        doc = catalogSnapshot.docs.first;
      } else {
        // Fallback a la colección antigua si es necesario
        final fallbackSnapshot = await _firestore
            .collection('achievements')
            .where('title', isEqualTo: title)
            .limit(1)
            .get();
        if (fallbackSnapshot.docs.isNotEmpty) {
          doc = fallbackSnapshot.docs.first;
        }
      }

      if (doc == null) {
        throw Exception('Logro no encontrado.');
      }

      final data = doc.data();
      return AchievementDetailEntity(
        title: data['title'] ?? title,
        description: data['description'] ?? 'Sin descripción disponible.',
      );
    } catch (e) {
      throw Exception('Error al obtener detalles del logro: $e');
    }
  }

  // --- Helpers ---
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchAchievementDefinitions(List<String> ids) async {
    if (ids.isEmpty) return [];

    final results = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    // Nombres de colecciones donde pueden estar las definiciones
    const sources = ['achievementsCatalog', 'achievements'];

    for (final source in sources) {
      final remainingIds = ids
          .where((id) => results.every((doc) => doc.id != id))
          .toList();
      if (remainingIds.isEmpty) {
        break;
      }

      // Firestore 'whereIn' solo soporta 10 items a la vez
      for (var i = 0; i < remainingIds.length; i += 10) {
        final end = (i + 10) > remainingIds.length
            ? remainingIds.length
            : i + 10;
        final slice = remainingIds.sublist(i, end);
        final snapshot = await _firestore
            .collection(source)
            .where(FieldPath.documentId, whereIn: slice)
            .get();
        results.addAll(snapshot.docs);
      }
    }
    return results;
  }
}
