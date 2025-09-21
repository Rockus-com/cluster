part of 'chats_cubit.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => [];
}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsLoaded extends ChatsState {
  final List<ChatModel> chats;

  const ChatsLoaded({required this.chats});

  @override
  List<Object> get props => [chats];
}

class UsersLoaded extends ChatsState {
  final List<UserModel> users;

  const UsersLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class ChatsActionInProgress extends ChatsState {}

class ChatCreatedSuccess extends ChatsState {}

class UserAddedSuccess extends ChatsState {}

class ChatsError extends ChatsState {
  final String message;

  const ChatsError({required this.message});

  @override
  List<Object> get props => [message];
}