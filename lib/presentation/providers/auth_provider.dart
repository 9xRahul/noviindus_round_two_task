import 'package:flutter/foundation.dart';
import 'package:noviindus_round_two_task/domain/use_cases/login_usecase.dart';
import '../../domain/entities/auth_entity.dart';

enum AuthState { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  AuthEntity? _auth;

  AuthProvider({required this.loginUseCase});

  AuthState get state {
    return _state;
  }

  String? get errorMessage {
    return _errorMessage;
  }

  AuthEntity? get auth {
    return _auth;
  }

  bool get loading {
    if (_state == AuthState.loading) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> login({
    required String countryCode,
    required String phone,
  }) async {
    _setState(AuthState.loading);
    try {
      final res = await loginUseCase.login(
        countryCode: countryCode,
        phone: phone,
      );
      _auth = res;
      _setState(AuthState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
    }
  }

  void _setState(AuthState s) {
    _state = s;
    notifyListeners();
  }

  void reset() {
    _state = AuthState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
