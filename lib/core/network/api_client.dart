import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 18);

  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl$path'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_timeout);
      return _decode(response);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on HttpException {
      throw const ApiException('The server could not be reached.');
    } on FormatException {
      throw const ApiException('The server returned invalid data.');
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(response);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on HttpException {
      throw const ApiException('The server could not be reached.');
    } on FormatException {
      throw const ApiException('The server returned invalid data.');
    }
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(_timeout);
      return _decode(response);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on HttpException {
      throw const ApiException('The server could not be reached.');
    } on FormatException {
      throw const ApiException('The server returned invalid data.');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message = decoded['message']?.toString() ?? message;
        }
      } catch (_) {
        // Keep the safe fallback message.
      }
      throw ApiException(message, statusCode: response.statusCode);
    }

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('The server returned an unexpected response.');
    }
    return decoded;
  }

  void close() => _client.close();
}
