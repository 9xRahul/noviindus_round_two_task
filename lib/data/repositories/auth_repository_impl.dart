import 'package:noviindus_round_two_task/data/datasource/remote_api_service.dart';
import 'package:noviindus_round_two_task/data/models/auth_models.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  RemoteApiService api;
  StorageService storage;

  AuthRepositoryImpl({required this.api, required this.storage});

  @override
  Future<AuthEntity> loginWithPhone({
    required String countryCode,
    required String phone,
  }) async {
    try {
      var body = {"country_code": countryCode, "phone": phone};

      print("Sending login body: $body");

      var response = await api.loginWithMobile("otp_verified", body);

      print("Login response: $response");

      var authModel = AuthModel.fromJson(response);

      if (authModel.accessToken == "" || authModel.accessToken.isEmpty) {
        throw Exception("Access token missing in response");
      }

      await storage.saveAccessToken(authModel.accessToken);
      return authModel;
    } catch (e) {
      print("Error in repository: $e");
      throw Exception("Login failed: $e");
    }
  }
}
