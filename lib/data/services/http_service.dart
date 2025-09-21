import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HttpService {
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters});
  Future<Response> post(String path, {dynamic data});
  Future<Response> put(String path, {dynamic data});
  Future<Response> delete(String path);
  void setAuthToken(String token);
  void removeAuthToken();
}

class HttpServiceImpl implements HttpService {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  HttpServiceImpl({required this.dio, required this.sharedPreferences}) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = sharedPreferences.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) {
        if (e.response?.statusCode == 401) {
          removeAuthToken();
          // Можно добавить навигацию на экран авторизации
        }
        return handler.next(e);
      },
    ));
  }

  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  @override
  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  @override
  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  @override
  Future<Response> delete(String path) {
    return dio.delete(path);
  }

  @override
  void setAuthToken(String token) {
    sharedPreferences.setString('auth_token', token);
  }

  @override
  void removeAuthToken() {
    sharedPreferences.remove('auth_token');
  }
}