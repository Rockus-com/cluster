import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/chat_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/usecases/chat_uc.dart';
import '../../domain/usecases/user_uc.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final LoadChatsUC loadChatsUC;
  final CreateChatUC createChatUC;
  final AddToChatUC addToChatUC;
  final LoadUsersUC loadUsersUC;

  ChatsCubit({
    required this.loadChatsUC,
    required this.createChatUC,
    required this.addToChatUC,
    required this.loadUsersUC,
  }) : super(ChatsInitial());

  Future<void> loadChats() async {
    emit(ChatsLoading());
    try {
      final chats = await loadChatsUC.execute();
      emit(ChatsLoaded(chats: chats));
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> createChat(String name, bool isGroup, List<String> memberIds) async {
    emit(ChatsActionInProgress());
    try {
      final chat = ChatModel(
        id: '',
        name: name,
        members: memberIds,
        createdAt: DateTime.now(),
        isGroup: isGroup,
      );
      await createChatUC.execute(chat);
      emit(ChatCreatedSuccess());
      await loadChats(); // Reload chats after creation
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> addUserToChat(String chatId, String userId) async {
    emit(ChatsActionInProgress());
    try {
      await addToChatUC.execute(chatId, userId);
      emit(UserAddedSuccess());
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> loadUsers() async {
    try {
      final users = await loadUsersUC.execute();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  void clearActionState() {
    if (state is ChatCreatedSuccess || state is UserAddedSuccess) {
      emit(ChatsLoaded(chats: (state as dynamic).chats ?? []));
    }
  }
}