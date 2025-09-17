import 'package:flutter/material.dart';
import 'package:noviindus_round_two_task/data/datasource/remote_api_service.dart';
import 'package:noviindus_round_two_task/domain/use_cases/login_usecase.dart';
import 'package:noviindus_round_two_task/presentation/screens/login_screen/login_screen.dart';
import 'package:provider/provider.dart';

import 'core/storage_service.dart';

import 'data/repositories/auth_repository_impl.dart';

import 'presentation/providers/auth_provider.dart';

void main() {
  final api = RemoteApiService();
  final storage = StorageService();

  final authRepo = AuthRepositoryImpl(api: api, storage: storage);
  final loginUseCase = LoginUseCase(repository: authRepo);

  runApp(MyApp(loginUseCase: loginUseCase));
}

class MyApp extends StatelessWidget {
  final LoginUseCase loginUseCase;
  const MyApp({required this.loginUseCase, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(loginUseCase: loginUseCase),
        ),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: ' Login',
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        home: const LoginScreen(),
      ),
    );
  }
}
