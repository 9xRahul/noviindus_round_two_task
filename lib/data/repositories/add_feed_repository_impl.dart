import 'dart:convert';
import '../../data/datasource/remote_api_service.dart';
import '../../core/storage_service.dart';

class AddFeedRepositoryImpl {
  final RemoteApiService api;
  final StorageService storage;

  AddFeedRepositoryImpl({required this.api, required this.storage});

  Future<Map<String, dynamic>> uploadFeed({
    required String videoPath,
    required String imagePath,
    required String desc,
    required List<int> categories,
  }) async {
    final String? token = await storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User not authenticated');
    }

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    final Map<String, String> fields = {
      'desc': desc,
      'category': json.encode(categories), 
    };

    final Map<String, String> files = {'video': videoPath, 'image': imagePath};

    final res = await api.uploadMultipart(
      path: 'my_feed',
      fields: fields,
      files: files,
      headers: headers,
    );
    return res;
  }
}
