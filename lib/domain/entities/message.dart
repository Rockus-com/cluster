// lib/domain/entities/message.dart
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String? id;
  final String chatId;
  final String senderId;
  final String content;
  final String? fileUrl;
  final DateTime? timestamp;

  Message({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.fileUrl,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}