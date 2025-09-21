import 'package:equatable/equatable.dart';

enum LoadingStatus { initial, loading, success, error }

class LoadingState<T> extends Equatable {
  final LoadingStatus status;
  final T? data;
  final String? error;

  const LoadingState({
    this.status = LoadingStatus.initial,
    this.data,
    this.error,
  });

  LoadingState<T> copyWith({
    LoadingStatus? status,
    T? data,
    String? error,
  }) {
    return LoadingState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}