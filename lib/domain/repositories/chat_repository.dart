import '../models/chat_model.dart';
import '../models/message_model.dart';

abstract class ChatRepository {
  Future<List<ChatModel>> getChats();
  Future<ChatModel> getChat(String id);
  Future<ChatModel> createChat(ChatModel chat);
  Future<ChatModel> updateChat(ChatModel chat);
  Future<void> deleteChat(String id);
  Future<void> addUserToChat(String chatId, String userId);
  Future<void> removeUserFromChat(String chatId, String userId);
  
  // Messages
  Future<List<MessageModel>> getMessages(String chatId);
  Future<MessageModel> sendMessage(MessageModel message);
  Future<MessageModel> editMessage(String messageId, String content);
  Future<void> deleteMessage(String messageId);
  
  // WebSocket
  Stream<MessageModel> listenForMessages(String chatId);
  void disconnectFromChat(String chatId);
}