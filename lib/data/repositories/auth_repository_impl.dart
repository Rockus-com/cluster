import 'package:dio/dio.dart';

import '../../../domain/models/user_model.dart';
import '../../../domain/models/token_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../services/http_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HttpService httpService;

  AuthRepositoryImpl({required this.httpService});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await httpService.post(
        '/token',
        data: {
          'username': username,
          'password': password,
        },
      );
      
      final token = TokenModel.fromJson(response.data);
      httpService.setAuthToken(token.accessToken);
      
      // Получаем данные пользователя
      final userResponse = await httpService.get('/users/me');
      return UserModel.fromJson(userResponse.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Login failed');
    }
  }

  @override
  Future<void> register(UserModel user, String password) async {
    try {
      await httpService.post(
        '/register',
        data: {
          ...user.toJson(),
          'password': password,
        },
      );
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Registration failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await httpService.post(
        '/forgot-password',
        data: {'email': email},
      );
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Password reset failed');
    }
  }

  @override
  Future<void> logout() async {
    httpService.removeAuthToken();
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await httpService.post(
        '/token/refresh',
        data: {'refresh_token': refreshToken},
      );
      return TokenModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Token refresh failed');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await httpService.getAuthToken();
    return token != null && token.isNotEmpty;
  }
}