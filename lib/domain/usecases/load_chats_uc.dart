// lib/domain/usecases/load_chats_uc.dart
import 'package:cluster/domain/services/chats_service.dart';
import 'package:cluster/domain/entities/chat.dart';

class LoadChatsUC {
  final ChatsService _service;

  LoadChatsUC(this._service);

  Future<List<Chat>> call() => _service.loadChats();
}