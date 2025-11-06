import 'package:bloodhero/domain/entities/user_entity.dart';
import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotifier extends Notifier<UserEntity?> {
  @override
  UserEntity? build() {
    return null;
  }

  Future<void> refresh() async {
    final repository = ref.read(centersRepositoryProvider);
    final profile = await repository.getUserProfile();
    state = profile;
  }

  void setUser(UserEntity user) {
    state = user;
  }

  void clear() {
    state = null;
  }
}

final userProvider = NotifierProvider<UserNotifier, UserEntity?>(
  UserNotifier.new,
);
