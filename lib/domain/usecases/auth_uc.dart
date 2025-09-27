// lib/domain/usecases/auth_uc.dart
import 'package:cluster/domain/services/users_service.dart';
import 'package:cluster/domain/entities/user.dart';

class AuthUC {
  final UsersService _service;

  AuthUC(this._service);

  Future<User> register(User user) => _service.register(user);
  Future<String> login(String username, String password) => _service.login(username, password);
  Future<void> forgotPassword(String email) => _service.forgotPassword(email);
}