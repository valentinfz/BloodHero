import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloodhero/domain/repositories/content_repository.dart';

class FirebaseContentRepository implements ContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<String>> getDonationTips() async {
    try {
      final querySnapshot = await _firestore
          .collection('donationTips')
          .where('deletedAt', isNull: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint(
          '[FirebaseContentRepository] No se encontraron documentos en la colección "donationTips".',
        );
        return [];
      }

      final List<String> tips = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('texto') && data['texto'] is String) {
          tips.add(data['texto'] as String);
        } else {
          debugPrint(
            '[FirebaseContentRepository] Documento ${doc.id} no tiene campo "texto" o no es un String.',
          );
        }
      }

      return tips;
    } catch (e, s) {
      debugPrint(
        '[FirebaseContentRepository] Error al obtener tips: $e\nStackTrace: $s',
      );
      return [];
    }
  }
}
