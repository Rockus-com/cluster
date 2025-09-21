import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String? fileUrl;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.fileUrl,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'],
      chatId: json['chat_id'] ?? json['chatId'],
      senderId: json['sender_id'] ?? json['senderId'],
      content: json['content'],
      fileUrl: json['file_url'] ?? json['fileUrl'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'file_url': fileUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? fileUrl,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        content,
        fileUrl,
        timestamp,
      ];
}