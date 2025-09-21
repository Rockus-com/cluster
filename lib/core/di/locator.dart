import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/http_service.dart';
import '../../data/services/websocket_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth_uc.dart';
import '../../domain/usecases/chat_uc.dart';
import '../../domain/usecases/task_uc.dart';
import '../../domain/usecases/user_uc.dart';
import '../../presentation/cubits/auth_cubit.dart';
import '../../presentation/cubits/chat_cubit.dart';
import '../../presentation/cubits/home_cubit.dart';
import '../../presentation/cubits/task_cubit.dart';
import '../../presentation/cubits/user_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: 5000,
    receiveTimeout: 3000,
  ));
  getIt.registerLazySingleton<Dio>(() => dio);

  // Services
  getIt.registerLazySingleton<HttpService>(() => HttpServiceImpl(dio: getIt()));
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketServiceImpl());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(httpService: getIt()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(httpService: getIt()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(httpService: getIt(), webSocketService: getIt()),
  );
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(httpService: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => AuthUC(authRepository: getIt()));
  getIt.registerLazySingleton(() => LoadUsersUC(userRepository: getIt()));
  getIt.registerLazySingleton(() => UpdateUserInfoUC(userRepository: getIt()));
  getIt.registerLazySingleton(() => LoadChatsUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => CreateChatUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => AddToChatUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => SendMessageUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => EditMessageUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => DeleteMessageUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => GetMessageUC(chatRepository: getIt()));
  getIt.registerLazySingleton(() => LoadTasksUC(taskRepository: getIt()));
  getIt.registerLazySingleton(() => CreateTaskUC(taskRepository: getIt()));
  getIt.registerLazySingleton(() => EditTaskUC(taskRepository: getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUC(taskRepository: getIt()));
  getIt.registerLazySingleton(() => CompleteTaskUC(taskRepository: getIt()));

  // Cubits
  getIt.registerFactory(() => AuthCubit(authUC: getIt()));
  getIt.registerFactory(() => HomeCubit(
        loadTasksUC: getIt(),
        loadChatsUC: getIt(),
      ));
  getIt.registerFactory(() => ChatsCubit(
        loadChatsUC: getIt(),
        createChatUC: getIt(),
        addToChatUC: getIt(),
        loadUsersUC: getIt(),
      ));
  getIt.registerFactory(() => ChatCubit(
        sendMessageUC: getIt(),
        editMessageUC: getIt(),
        deleteMessageUC: getIt(),
        getMessageUC: getIt(),
      ));
  getIt.registerFactory(() => TasksCubit(
        loadTasksUC: getIt(),
        createTaskUC: getIt(),
        loadUsersUC: getIt(),
      ));
  getIt.registerFactory(() => TaskCubit(
        editTaskUC: getIt(),
        deleteTaskUC: getIt(),
        completeTaskUC: getIt(),
      ));
  getIt.registerFactory(() => AboutCubit(updateUserInfoUC: getIt()));
  getIt.registerFactory(() => SettingsCubit());
}