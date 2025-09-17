import 'dart:convert';
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
}
