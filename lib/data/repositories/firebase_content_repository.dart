import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloodhero/domain/repositories/content_repository.dart';

class FirebaseContentRepository implements ContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<String>> getDonationTips() async {
    // Podríamos leerlos de una colección 'tips' en Firestore
    // TODO: Por ahora, se mantiene la lógica fake
    await Future.delayed(const Duration(milliseconds: 100)); // Simula carga
    return [
      'Recordá hidratarte bien antes y después de donar.',
      'Avisá al personal si te sentís mareado en algún momento.',
      'Evitá hacer actividad física intensa el día de la donación.',
    ];
  }
}
