class RegisterRequest {
  final String name;
  final String username;
  final String email;
  final String password;
  final String passwordRepeat;

  const RegisterRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordRepeat,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "passwordRepeat": passwordRepeat,
        "profilePictureUrl": "",
        "phoneNumber": "",
        "bio": "",
        "website": "",
      };
}
