class UserProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? website;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.website,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id: (m['id'] ?? m['_id'] ?? '').toString(),
    name: (m['name'] ?? m['fullName'] ?? m['username'] ?? '').toString(),
    username: (m['username'] ?? '').toString(),
    email: (m['email'] ?? '').toString(),
    avatarUrl: (m['profilePictureUrl'] ?? m['avatar']) as String?,
    bio: m['bio'] as String?,
    website: m['website'] as String?,
  );
}
