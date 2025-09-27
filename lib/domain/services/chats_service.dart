// lib/domain/services/chats_service.dart
import 'package:cluster/data/repositories/chats_repo.dart';
import 'package:cluster/domain/entities/chat.dart';
import 'package:cluster/domain/entities/message.dart';

class ChatsService {
  final ChatsRepo _repo;

  ChatsService(this._repo);

  Future<List<Chat>> loadChats() => _repo.loadChats();
  Future<Chat> createChat(Chat chat) => _repo.createChat(chat);
  Future<void> addToChat(String chatId, String memberId) => _repo.addToChat(chatId, memberId);
  Future<List<Message>> getMessages(String chatId) => _repo.getMessages(chatId);
  Future<void> sendMessage(Message message) => _repo.sendMessage(message);
  Future<void> editMessage(String messageId, String content) => _repo.editMessage(messageId, content);
  Future<void> deleteMessage(String messageId) => _repo.deleteMessage(messageId);
}