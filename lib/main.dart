import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage_service.dart';
import 'data/datasource/remote_api_service.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'domain/use_cases/login_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen/login_screen.dart';

import 'data/repositories/add_feed_repository_impl.dart';
import 'domain/use_cases/upload_feed_usecase.dart';
import 'presentation/providers/add_feed_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final RemoteApiService api = RemoteApiService();
  final StorageService storage = StorageService();

  final AuthRepositoryImpl authRepo = AuthRepositoryImpl(
    api: api,
    storage: storage,
  );
  final LoginUseCase loginUseCase = LoginUseCase(repository: authRepo);
  final AuthProvider authProvider = AuthProvider(loginUseCase: loginUseCase);

  final AddFeedRepositoryImpl addFeedRepo = AddFeedRepositoryImpl(
    api: api,
    storage: storage,
  );
  final UploadFeedUseCase uploadFeedUseCase = UploadFeedUseCase(
    repository: addFeedRepo,
  );
  final AddFeedProvider addFeedProvider = AddFeedProvider(
    uploadUseCase: uploadFeedUseCase,
    storage: storage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AddFeedProvider>.value(value: addFeedProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noviindus Demo',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const LoginScreen(),
    );
  }
}
