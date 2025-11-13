import '../entities/history_item_entity.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Obtiene el perfil público del usuario actual.
  Future<UserEntity> getUserProfile();

  /// Actualiza los datos básicos del usuario.
  Future<void> updateUserProfile(Map<String, dynamic> data);

  /// Marca la cuenta como eliminada (borrado lógico).
  Future<void> deleteUserAccount();

  /// Obtiene el historial de donaciones (citas pasadas).
  Future<List<HistoryItemEntity>> getDonationHistory();
}
