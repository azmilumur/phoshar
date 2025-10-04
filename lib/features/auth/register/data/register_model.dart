import 'dart:convert';

import '../domain/register.dart';

class RegisterRequestModel {
  String name;
  String username;
  String email;
  String password;
  String passwordRepeat;

  RegisterRequestModel({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordRepeat,
  });

  // Convert dari domain entity
  factory RegisterRequestModel.fromEntity(RegisterRequest entity) {
    return RegisterRequestModel(
      email: entity.email,
      password: entity.password,
      name: entity.name,
      username: entity.username,
      passwordRepeat: entity.passwordRepeat,
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "username": username,
    "email": email,
    "password": password,
    "passwordRepeat": passwordRepeat,
  };
}

class DataModel {
  String name;
  String username;
  String email;
  String password;

  DataModel({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  Data toEntity() {
    return Data(
      // This should return domain Data, not User
      name: name,
      username: username,
      email: email,
      password: password,
    );
  }
}

// Response Model
class RegisterResponseModel {
  String code;
  String status;
  String message;
  DataModel data;

  RegisterResponseModel({
    required this.code,
    required this.status,
    required this.message,
    required this.data,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: DataModel.fromJson(json['data'] ?? {}),
    );
  }

  // Convert ke domain entity
  RegisterResponse toEntity() {
    return RegisterResponse(
      code: code,
      status: status,
      message: message,
      data: data.toEntity(),
    );
  }
}

RegisterRequestModel registerRequestFromJson(String str) =>
    RegisterRequestModel.fromEntity(
      RegisterRequest(
        email: json.decode(str)['email'],
        password: json.decode(str)['password'],
        name: json.decode(str)['name'],
        username: json.decode(str)['username'],
        passwordRepeat: json.decode(str)['passwordRepeat'],
      ),
    );

String registerRequestToJson(RegisterRequestModel data) =>
    json.encode(data.toJson());
