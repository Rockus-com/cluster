// lib/data/repositories/users_repo.dart
import 'package:cluster/data/repositories/http_repo.dart';
import 'package:cluster/data/repositories/websocket_repo.dart';
import 'package:cluster/data/repositories/cache_repo.dart';
import 'package:cluster/domain/entities/user.dart';

abstract class UsersRepo {
  Future<User> register(User user);
  Future<String> login(String username, String password);
  Future<void> forgotPassword(String email);
  Future<List<User>> loadUsers();
  Future<void> updateUser(User user);
}

class UsersRepoImpl implements UsersRepo {
  final HttpRepo _httpRepo;
  final WebSocketRepo _wsRepo;
  final CacheRepo _cacheRepo;

  UsersRepoImpl(this._httpRepo, this._wsRepo, this._cacheRepo);

  @override
  Future<User> register(User user) async {
    final response = await _httpRepo.post('/register', user.toJson());
    return User.fromJson(response.data);
  }

  @override
  Future<String> login(String username, String password) async {
    final response = await _httpRepo.post('/token', {
      'username': username,
      'password': password,
    });
    final token = response.data['access_token'];
    await _cacheRepo.save('access_token', token);
    return token;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _httpRepo.post('/forgot-password', {'email': email});
  }

  @override
  Future<List<User>> loadUsers() async {
    final response = await _httpRepo.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await _httpRepo.put('/users/me', user.toJson());
  }
}