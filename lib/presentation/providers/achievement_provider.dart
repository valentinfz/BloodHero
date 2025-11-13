import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/achievement_detail_entity.dart';

// Provider.family para obtener los detalles de UN logro específico por su título
final achievementDetailProvider = FutureProvider.autoDispose
    .family<AchievementDetailEntity, String>((ref, achievementTitle) {
      final repository = ref.watch(impactRepositoryProvider);
      return repository.getAchievementDetails(achievementTitle);
    });
