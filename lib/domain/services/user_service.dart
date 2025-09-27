// lib/domain/services/users_service.dart
import 'package:cluster/data/repositories/users_repo.dart';
import 'package:cluster/domain/entities/user.dart';

class UsersService {
  final UsersRepo _repo;

  UsersService(this._repo);

  Future<User> register(User user) => _repo.register(user);
  Future<String> login(String username, String password) => _repo.login(username, password);
  Future<void> forgotPassword(String email) => _repo.forgotPassword(email);
  Future<List<User>> loadUsers() => _repo.loadUsers();
  Future<void> updateUser(User user) => _repo.updateUser(user);
}