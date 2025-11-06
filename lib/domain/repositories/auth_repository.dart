abstract class AuthRepository {
  Future<void> login(String email, String password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String bloodType,
    required String city,
  });

  Future<void> forgotPassword(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> deleteAccount();
}
