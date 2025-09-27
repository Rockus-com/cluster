// lib/data/repositories/websocket_repo.dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cluster/core/constants.dart';

abstract class WebSocketRepo {
  WebSocketChannel connect(String chatId, String token);
  void sendMessage(WebSocketChannel channel, Map<String, dynamic> message);
  Stream<dynamic> getStream(WebSocketChannel channel);
  void disconnect(WebSocketChannel channel);
}

class WebSocketRepoImpl implements WebSocketRepo {
  @override
  WebSocketChannel connect(String chatId, String token) {
    return WebSocketChannel.connect(Uri.parse('$wsBaseUrl/chats/$chatId?token=$token'));
  }

  @override
  void sendMessage(WebSocketChannel channel, Map<String, dynamic> message) {
    channel.sink.add(message);
  }

  @override
  Stream<dynamic> getStream(WebSocketChannel channel) {
    return channel.stream;
  }

  @override
  void disconnect(WebSocketChannel channel) {
    channel.sink.close();
  }
}