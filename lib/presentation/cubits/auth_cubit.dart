import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/user_model.dart';
import '../../domain/usecases/auth_uc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUC authUC;

  AuthCubit({required this.authUC}) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await authUC.execute(username, password);
      emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> register(UserModel user, String password) async {
    emit(AuthLoading());
    try {
      await authUC.executeRegister(user, password);
      // После регистрации автоматически логинимся
      await login(user.username, password);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await authUC.executeForgotPassword(email);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void logout() {
    authUC.executeLogout();
    emit(AuthInitial());
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }
}