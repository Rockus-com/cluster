// lib/data/repositories/http_repo.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cluster/core/constants.dart';

abstract class HttpRepo {
  Future<Response> get(String path);
  Future<Response> post(String path, dynamic data);
  Future<Response> put(String path, dynamic data);
  Future<Response> delete(String path);
  Future<String> uploadFile(String filePath);
}

class HttpRepoImpl implements HttpRepo {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  HttpRepoImpl(this._dio, this._storage) {
    _dio.options.baseUrl = apiBaseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  @override
  Future<Response> get(String path) => _dio.get(path);

  @override
  Future<Response> post(String path, dynamic data) => _dio.post(path, data: data);

  @override
  Future<Response> put(String path, dynamic data) => _dio.put(path, data: data);

  @override
  Future<Response> delete(String path) => _dio.delete(path);

  @override
  Future<String> uploadFile(String filePath) async {
    // Implement file upload using dio
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/upload-file', data: formData);
    return response.data['file_url'];
  }
}