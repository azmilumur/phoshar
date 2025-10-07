// lib/features/posts/data/photo.dart
import 'comment.dart';

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
  final String userId;
  final String imageUrl;

  /// opsional dari server
  final String? caption;
  final int? totalLikes;
  final bool? isLike;
  final BasicUser? user;
  final List<CommentModel>? comments;

  /// contoh: "2023-11-04T00:51:43.551Z"
  final String? createdAt;

  Photo({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.totalLikes,
    this.isLike,
    this.user,
    this.createdAt,
    this.comments,
  });

  factory Photo.fromJson(Map<String, dynamic> m) => Photo(
    id: (m['id'] ?? '').toString(),
    userId: (m['userId'] ?? m['user_id'] ?? '').toString(),
    imageUrl: (m['imageUrl'] ?? m['image_url'] ?? '').toString(),
    caption: m['caption'] as String?,
    totalLikes: (m['totalLikes'] as num?)?.toInt(),
    isLike: m['isLike'] as bool?,
    user: m['user'] is Map<String, dynamic>
        ? BasicUser.fromJson(m['user'] as Map<String, dynamic>)
        : null,
    createdAt: m['createdAt']?.toString(),
    comments: (m['comments'] as List?)
        ?.whereType<Map>()
        .map((e) => CommentModel.fromMap(e.cast<String, dynamic>()))
        .toList(),
  );

  Photo copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    bool? isLike,
    int? totalLikes,
    BasicUser? user,
    List<CommentModel>? comments,
    String? createdAt,
  }) {
    return Photo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      isLike: isLike ?? this.isLike,
      totalLikes: totalLikes ?? this.totalLikes,
      user: user ?? this.user,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===== Helper non-null untuk dipakai di UI =====
  bool get liked => isLike ?? false; // aman buat kondisi
  int get likeCount => totalLikes ?? 0; // aman buat angka likes

  /// UTC DateTime dari createdAt (null kalau parsing gagal)
  DateTime? get createdAtUtc =>
      createdAt == null ? null : DateTime.tryParse(createdAt!);

  /// buat sorting DESC (yang null dianggap paling tua)
  int get createdAtEpoch => createdAtUtc?.millisecondsSinceEpoch ?? 0;

  /// kalau perlu dipakai untuk "time ago" lokal
  DateTime? get createdAtLocal => createdAtUtc?.toLocal();
}
