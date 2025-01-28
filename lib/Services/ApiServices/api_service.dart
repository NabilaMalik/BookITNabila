import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class ApiService extends GetxService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
  static Future<List<dynamic>> getData(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['items']; // Extract the list from 'items'
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> postRequest( Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          throw Exception('Empty response body');
        }
        return json.decode(response.body);
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
      case 403:
        throw Exception('Unauthorized: ${response.body}');
      case 500:
      default:
        throw Exception('Server error (${response.statusCode}): ${response.body}');
    }
  }

}
