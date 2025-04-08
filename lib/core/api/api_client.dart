import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Move Base URL to a configuration file or environment variable
const String _baseUrl =
    'https://api.alquran.cloud/v1'; // Example using alquran.cloud

// Provider for the Dio instance
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = _baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10); // 10 seconds
  dio.options.receiveTimeout = const Duration(seconds: 10);

  // Optional: Add interceptors for logging, error handling, etc.
  // dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
});
