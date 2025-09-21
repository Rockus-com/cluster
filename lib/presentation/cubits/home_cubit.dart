import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/models/chat_model.dart';
import '../../domain/models/task_model.dart';
import '../../domain/usecases/chat_uc.dart';
import '../../domain/usecases/task_uc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final LoadTasksUC loadTasksUC;
  final LoadChatsUC loadChatsUC;

  HomeCubit({
    required this.loadTasksUC,
    required this.loadChatsUC,
  }) : super(HomeInitial());

  Future<void> loadData() async {
    emit(HomeLoading());
    try {
      final tasks = await loadTasksUC.execute();
      final chats = await loadChatsUC.execute();
      emit(HomeLoaded(tasks: tasks, chats: chats));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void refresh() {
    emit(HomeInitial());
    loadData();
  }
}