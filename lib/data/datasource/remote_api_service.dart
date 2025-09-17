import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class RemoteApiService {
  String baseUrl = AppConstants.baseUrl;

  Future<Map<String, dynamic>> loginWithMobile(
    String path,
    Map<String, dynamic> body,
  ) async {
    var url = Uri.parse(baseUrl + path);

    print("Login request body: $body");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.body == "" || response.body.isEmpty) {
      throw Exception("Empty response from server");
    }

    var data = json.decode(response.body);

    if (response.statusCode == 202) {
      return data;
    } else {
      var errorMsg = "Something went wrong";
      if (data is Map && data.containsKey("message")) {
        errorMsg = data["message"];
      } else if (data is Map && data.containsKey("error")) {
        errorMsg = data["error"];
      }
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final url = '$baseUrl$path';
    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 202) {
        final Map<String, dynamic> body = json.decode(res.body);
        return body;
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to GET $path : $e');
    }
  }

  Future<Map<String, dynamic>> uploadMultipart({
    required String path,
    required Map<String, String> fields,
    required Map<String, String> files,
    Map<String, String>? headers,
  }) async {
    final String url = '$baseUrl$path';
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      if (headers != null) {
        request.headers.addAll(headers);
      }

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      for (final entry in files.entries) {
        final String fieldName = entry.key;
        final String filePath = entry.value;
        final file = File(filePath);
        if (!file.existsSync()) {
          throw Exception('File not found: $filePath');
        }
        final multipartFile = await http.MultipartFile.fromPath(
          fieldName,
          filePath,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 202) {
        final Map<String, dynamic> decoded =
            json.decode(response.body) as Map<String, dynamic>;
        print(response.body);
        return decoded;
      } else {
        final Map<String, dynamic> decoded = response.body.isNotEmpty
            ? json.decode(response.body) as Map<String, dynamic>
            : {};
        final msg =
            decoded['message'] ??
            decoded['error'] ??
            'Upload failed with status ${response.statusCode}';
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception('Multipart upload failed: $e');
    }
  }
}
