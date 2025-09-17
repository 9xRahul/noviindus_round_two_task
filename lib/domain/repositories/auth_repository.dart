import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> loginWithPhone({
    required String countryCode,
    required String phone,
  });
}
