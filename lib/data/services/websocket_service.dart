import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

abstract class WebSocketService {
  Stream<dynamic> connectToChat(String chatId);
  void disconnectFromChat(String chatId);
  void sendMessage(String chatId, dynamic message);
}

class WebSocketServiceImpl implements WebSocketService {
  final Map<String, WebSocketChannel> _connections = {};
  final Map<String, StreamController<dynamic>> _streamControllers = {};

  @override
  Stream<dynamic> connectToChat(String chatId) {
    if (_connections.containsKey(chatId)) {
      return _streamControllers[chatId]!.stream;
    }

    final token = ''; // Получить токен из хранилища
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8000/ws/chats/$chatId?token=$token'),
    );

    _connections[chatId] = channel;
    final controller = StreamController<dynamic>();
    _streamControllers[chatId] = controller;

    channel.stream.listen(
      (data) {
        final messageData = json.decode(data);
        controller.add(messageData);
      },
      onError: (error) {
        controller.addError(error);
      },
      onDone: () {
        controller.close();
        _connections.remove(chatId);
        _streamControllers.remove(chatId);
      },
    );

    return controller.stream;
  }

  @override
  void disconnectFromChat(String chatId) {
    if (_connections.containsKey(chatId)) {
      _connections[chatId]!.sink.close();
      _connections.remove(chatId);
    }
    
    if (_streamControllers.containsKey(chatId)) {
      _streamControllers[chatId]!.close();
      _streamControllers.remove(chatId);
    }
  }

  @override
  void sendMessage(String chatId, dynamic message) {
    if (_connections.containsKey(chatId)) {
      _connections[chatId]!.sink.add(json.encode(message));
    }
  }
}