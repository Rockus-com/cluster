import 'package:dio/dio.dart';

import '../../../domain/models/user_model.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../services/http_service.dart';

class UserRepositoryImpl implements UserRepository {
  final HttpService httpService;

  UserRepositoryImpl({required this.httpService});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await httpService.get('/users');
      final List<dynamic> usersData = response.data;
      return usersData.map((data) => UserModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load users');
    }
  }

  @override
  Future<UserModel> getUser(String id) async {
    try {
      final response = await httpService.get('/users/$id');
      return UserModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load user');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await httpService.put(
        '/users/me',
        data: user.toJson(),
      );
      return UserModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update user');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await httpService.delete('/users/$id');
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete user');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await httpService.get('/users/me');
      return UserModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load current user');
    }
  }
}