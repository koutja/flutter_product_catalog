// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

import 'package:dio/dio.dart';

import 'client/client_api_client.dart';

/// JSON Server API for Products `v1.0.0`.
///
/// REST API for managing products using typicode/json-server.
class MainApiClient {
  MainApiClient(
    Dio dio, {
    String? baseUrl,
  }) : _dio = dio,
       _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  ClientApiClient? _client;

  ClientApiClient get client => _client ??= ClientApiClient(_dio, baseUrl: _baseUrl);
}
