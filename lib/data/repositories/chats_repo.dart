// lib/data/repositories/chats_repo.dart
import 'package:cluster/data/repositories/http_repo.dart';
import 'package:cluster/data/repositories/websocket_repo.dart';
import 'package:cluster/data/repositories/cache_repo.dart';
import 'package:cluster/domain/entities/chat.dart';
import 'package:cluster/domain/entities/message.dart';

abstract class ChatsRepo {
  Future<List<Chat>> loadChats();
  Future<Chat> createChat(Chat chat);
  Future<void> addToChat(String chatId, String memberId);
  Future<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> editMessage(String messageId, String content);
  Future<void> deleteMessage(String messageId);
}

class ChatsRepoImpl implements ChatsRepo {
  final HttpRepo _httpRepo;
  final WebSocketRepo _wsRepo;
  final CacheRepo _cacheRepo;

  ChatsRepoImpl(this._httpRepo, this._wsRepo, this._cacheRepo);

  @override
  Future<List<Chat>> loadChats() async {
    final response = await _httpRepo.get('/chats');
    return (response.data as List).map((e) => Chat.fromJson(e)).toList();
  }

  @override
  Future<Chat> createChat(Chat chat) async {
    final response = await _httpRepo.post('/chats', chat.toJson());
    return Chat.fromJson(response.data);
  }

  @override
  Future<void> addToChat(String chatId, String memberId) async {
    await _httpRepo.post('/chats/$chatId/add-member', {'member_id': memberId});
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final response = await _httpRepo.get('/chats/$chatId/messages');
    return (response.data as List).map((e) => Message.fromJson(e)).toList();
  }

  @override
  Future<void> sendMessage(Message message) async {
    // For HTTP fallback, but prefer WS
    // await _httpRepo.post('/messages', message.toJson());
    // But since WS is used, this is handled in service
  }

  @override
  Future<void> editMessage(String messageId, String content) async {
    await _httpRepo.put('/messages/$messageId', {'content': content});
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _httpRepo.delete('/messages/$messageId');
  }
}