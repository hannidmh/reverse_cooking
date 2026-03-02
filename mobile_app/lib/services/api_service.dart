import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/config.dart';
import '../models/models.dart';

class ApiService {
  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
        ));

  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: 'access_token');

  Future<void> saveToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'access_token');

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<ScanResponse> scanImage(File image, {int servings = 2}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path),
      'servings': servings,
      'min_confidence': 0.7,
    });
    final res = await _dio.post(
      '/api/scan',
      data: formData,
      options: Options(headers: await _headers()),
    );
    return ScanResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<HistoryItem>> getHistory() async {
    final res = await _dio.get(
      '/api/history',
      options: Options(headers: await _headers()),
    );
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(HistoryItem.fromJson).toList();
  }

  Future<List<FavoriteItem>> getFavorites() async {
    final res = await _dio.get(
      '/api/favorites',
      options: Options(headers: await _headers()),
    );
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(FavoriteItem.fromJson).toList();
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get(
      '/api/profile',
      options: Options(headers: await _headers()),
    );
    return res.data as Map<String, dynamic>;
  }
}
