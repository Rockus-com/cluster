import '../models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(String id);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String id);
  Future<UserModel> getCurrentUser();
}