import 'package:equatable/equatable.dart';

class TokenModel extends Equatable {
  final String accessToken;
  final String tokenType;

  const TokenModel({
    required this.accessToken,
    required this.tokenType,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  @override
  List<Object?> get props => [accessToken, tokenType];
}