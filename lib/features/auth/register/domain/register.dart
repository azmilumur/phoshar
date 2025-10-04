class RegisterRequest {
  String name;
  String username;
  String email;
  String password;
  String passwordRepeat;

  RegisterRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordRepeat,
  });
}

class RegisterResponse {
  String code;
  String status;
  String message;
  Data data;

  RegisterResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.data,
  });
}

class Data {
  String name;
  String username;
  String email;
  String password;

  Data({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });
}
