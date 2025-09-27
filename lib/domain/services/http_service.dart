// lib/domain/services/http_service.dart
import 'package:cluster/data/repositories/users_repo.dart';

class HttpService {
  final UsersRepo usersRepo;

  HttpService(this.usersRepo);

  // Base HTTP operations, but since repo handles, perhaps not needed
}