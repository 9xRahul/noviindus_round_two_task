import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase({required this.repository});

  Future<AuthEntity> login({
    required String countryCode,
    required String phone,
  }) {
    return repository.loginWithPhone(countryCode: countryCode, phone: phone);
  }

}
