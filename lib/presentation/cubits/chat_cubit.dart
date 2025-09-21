import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/message_model.dart';
import '../../domain/usecases/chat_uc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final SendMessageUC sendMessageUC;
  final EditMessageUC editMessageUC;
  final DeleteMessageUC deleteMessageUC;
  final GetMessageUC getMessageUC;

  ChatCubit({
    required this.sendMessageUC,
    required this.editMessageUC,
    required this.deleteMessageUC,
    required this.getMessageUC,
  }) : super(ChatInitial());

  Future<void> loadMessages(String chatId) async {
    emit(ChatLoading());
    try {
      final messages = await getMessageUC.execute(chatId);
      emit(ChatLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String content, {String? fileUrl}) async {
    emit(MessageSending());
    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        content: content,
        fileUrl: fileUrl,
        timestamp: DateTime.now(),
      );
      await sendMessageUC.execute(message);
      emit(MessageSentSuccess());
      await loadMessages(chatId); // Reload messages after sending
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> editMessage(String messageId, String content) async {
    emit(MessageEditing());
    try {
      await editMessageUC.execute(messageId, content);
      emit(MessageEditedSuccess());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    emit(MessageDeleting());
    try {
      await deleteMessageUC.execute(messageId);
      emit(MessageDeletedSuccess());
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void clearActionState() {
    if (state is MessageSentSuccess || 
        state is MessageEditedSuccess || 
        state is MessageDeletedSuccess) {
      final currentState = state as dynamic;
      emit(ChatLoaded(messages: currentState.messages ?? []));
    }
  }
}