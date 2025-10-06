// lib/features/posts/data/photo.dart
class BasicUser {
  final String id;
  final String username; // selalu ada (fallback ke prefix email)
  final String? email;
  final String? profilePictureUrl;

  const BasicUser({
    required this.id,
    required this.username,
    this.email,
    this.profilePictureUrl,
  });

  factory BasicUser.fromJson(Map<String, dynamic> m) => _fromAny(m);
  factory BasicUser.fromMap(Map<String, dynamic> m) => _fromAny(m);

  static BasicUser _fromAny(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final rawUsername = (m['username'] ?? '').toString();
    final email = m['email'] as String?;
    final pic =
        (m['profilePictureUrl'] ?? m['profile_picture_url'] ?? m['avatar'])
            as String?;

    final username = rawUsername.isNotEmpty
        ? rawUsername
        : (email != null && email.isNotEmpty ? email.split('@').first : 'User');

    return BasicUser(
      id: id,
      username: username,
      email: email,
      profilePictureUrl: pic,
    );
  }

  String get displayName =>
      username.isNotEmpty ? username : (email?.split('@').first ?? 'User');
}

class Photo {
  final String id;
  final String imageUrl;
  final String? caption;
  final int? totalLikes;
  final bool? isLike;
  final BasicUser? user;

  /// Server kirim ISO string, contoh: "2023-11-04T00:51:43.551Z"
  final String? createdAt;

  Photo({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.totalLikes,
    this.isLike,
    this.user,
    this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> m) => Photo(
    id: (m['id'] ?? '').toString(),
    imageUrl: (m['imageUrl'] ?? '').toString(),
    caption: m['caption'] as String?,
    totalLikes: (m['totalLikes'] as num?)?.toInt(),
    isLike: m['isLike'] as bool?,
    user: m['user'] == null
        ? null
        : BasicUser.fromJson(m['user'] as Map<String, dynamic>),
    createdAt: m['createdAt']?.toString(),
  );

  /// untuk sorting DESC dengan aman
  int get createdAtEpoch {
    final s = createdAt;
    if (s == null || s.isEmpty) return 0;
    final dt = DateTime.tryParse(s); // "Z" -> UTC aman
    return dt?.millisecondsSinceEpoch ?? 0;
  }

  /// kalau perlu tampilan "time ago" pakai local
  DateTime? get createdAtLocal =>
      createdAt == null ? null : DateTime.tryParse(createdAt!)?.toLocal();
}
