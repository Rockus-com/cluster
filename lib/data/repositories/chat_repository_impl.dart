import 'dart:async';
import 'package:dio/dio.dart';

import '../../../domain/models/chat_model.dart';
import '../../../domain/models/message_model.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../services/http_service.dart';
import '../../services/websocket_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final HttpService httpService;
  final WebSocketService webSocketService;
  final Map<String, StreamController<MessageModel>> _messageStreams = {};

  ChatRepositoryImpl({
    required this.httpService,
    required this.webSocketService,
  });

  @override
  Future<List<ChatModel>> getChats() async {
    try {
      final response = await httpService.get('/chats');
      final List<dynamic> chatsData = response.data;
      return chatsData.map((data) => ChatModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load chats');
    }
  }

  @override
  Future<ChatModel> getChat(String id) async {
    try {
      final response = await httpService.get('/chats/$id');
      return ChatModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load chat');
    }
  }

  @override
  Future<ChatModel> createChat(ChatModel chat) async {
    try {
      final response = await httpService.post(
        '/chats',
        data: chat.toJson(),
      );
      return ChatModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create chat');
    }
  }

  @override
  Future<ChatModel> updateChat(ChatModel chat) async {
    try {
      final response = await httpService.put(
        '/chats/${chat.id}',
        data: chat.toJson(),
      );
      return ChatModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to update chat');
    }
  }

  @override
  Future<void> deleteChat(String id) async {
    try {
      await httpService.delete('/chats/$id');
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete chat');
    }
  }

  @override
  Future<void> addUserToChat(String chatId, String userId) async {
    try {
      await httpService.post(
        '/chats/$chatId/add-member',
        data: {'member_id': userId},
      );
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to add user to chat');
    }
  }

  @override
  Future<void> removeUserFromChat(String chatId, String userId) async {
    try {
      await httpService.delete(
        '/chats/$chatId/remove-member/$userId',
      );
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to remove user from chat');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await httpService.get('/chats/$chatId/messages');
      final List<dynamic> messagesData = response.data;
      return messagesData.map((data) => MessageModel.fromJson(data)).toList();
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load messages');
    }
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final response = await httpService.post(
        '/messages',
        data: message.toJson(),
      );
      return MessageModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to send message');
    }
  }

  @override
  Future<MessageModel> editMessage(String messageId, String content) async {
    try {
      final response = await httpService.put(
        '/messages/$messageId',
        data: {'content': content},
      );
      return MessageModel.fromJson(response.data);
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to edit message');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await httpService.delete('/messages/$messageId');
    } on DioError catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to delete message');
    }
  }

  @override
  Stream<MessageModel> listenForMessages(String chatId) {
    if (!_messageStreams.containsKey(chatId)) {
      final controller = StreamController<MessageModel>();
      _messageStreams[chatId] = controller;
      
      // Connect to WebSocket
      webSocketService.connectToChat(chatId).listen((messageData) {
        final message = MessageModel.fromJson(messageData);
        controller.add(message);
      }, onError: (error) {
        controller.addError(error);
      }, onDone: () {
        controller.close();
        _messageStreams.remove(chatId);
      });
    }
    
    return _messageStreams[chatId]!.stream;
  }

  @override
  void disconnectFromChat(String chatId) {
    webSocketService.disconnectFromChat(chatId);
    if (_messageStreams.containsKey(chatId)) {
      _messageStreams[chatId]!.close();
      _messageStreams.remove(chatId);
    }
  }
}