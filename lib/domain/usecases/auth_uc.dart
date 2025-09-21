// domain/usecases/auth_uc.dart
class AuthUC {
  final AuthRepository authRepository;

  AuthUC({required this.authRepository});

  Future<UserModel> executeLogin(String username, String password) {
    return authRepository.login(username, password);
  }

  Future<void> executeRegister(UserModel user, String password) {
    return authRepository.register(user, password);
  }

  Future<void> executeForgotPassword(String email) {
    return authRepository.forgotPassword(email);
  }
}