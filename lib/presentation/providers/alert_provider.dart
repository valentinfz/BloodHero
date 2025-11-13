import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/alert_detail_entity.dart';

// Provider.family para obtener los detalles de UNA alerta específica
final alertDetailProvider = FutureProvider.autoDispose
    .family<AlertDetailEntity, String>((ref, identifier) {
      final repository = ref.watch(alertsRepositoryProvider);
      return repository.getAlertDetails(identifier);
    });
