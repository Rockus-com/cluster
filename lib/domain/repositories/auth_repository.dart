import '../models/user_model.dart';
import '../models/token_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String username, String password);
  Future<void> register(UserModel user, String password);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<TokenModel> refreshToken(String refreshToken);
  Future<bool> isLoggedIn();
}