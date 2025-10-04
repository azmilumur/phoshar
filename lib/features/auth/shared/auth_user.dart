class AuthUser {
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? role;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? bio;
  final String? website;

  const AuthUser({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.role,
    this.profilePictureUrl,
    this.phoneNumber,
    this.bio,
    this.website,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) => AuthUser(
    id: (map['id'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    username: map['username'] as String?,
    name: map['name'] as String?,
    role: map['role'] as String?,
    profilePictureUrl: map['profilePictureUrl'] as String?,
    phoneNumber: map['phoneNumber'] as String?,
    bio: map['bio'] as String?,
    website: map['website'] as String?,
  );
}
