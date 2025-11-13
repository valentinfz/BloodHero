import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item_entity.dart';

final donationHistoryProvider =
    FutureProvider.autoDispose<List<HistoryItemEntity>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return repository.getDonationHistory();
    });
