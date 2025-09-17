import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  final bool status;
  final bool privilage;

  final String accessToken;
  final String? refreshToken;
  final String phone;

  AuthModel({
    required this.status,
    required this.privilage,
    required this.accessToken,
    required this.phone,
    this.refreshToken,
  }) : super(accessToken: accessToken, phone: phone);

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as Map<String, dynamic>? ?? {};
    return AuthModel(
      status: json['status'] as bool? ?? false,
      privilage: json['privilage'] as bool? ?? false,
      accessToken: token['access'] as String? ?? '',
      refreshToken: token['refresh'] as String?,
      phone: (json['phone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'privilage': privilage,
      'token': {'access': accessToken, 'refresh': refreshToken},
      'phone': phone,
    };
  }
}
