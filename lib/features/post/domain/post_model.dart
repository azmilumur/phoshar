import 'comment_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final bool isLike;
  final int totalLikes;
  final UserModel? user;
  final List<CommentModel>? comments;
  final String? createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.caption,
    required this.isLike,
    required this.totalLikes,
    this.user,
    this.comments,
    this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      isLike: map['isLike'] ?? false,
      totalLikes: map['totalLikes'] ?? 0,
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
      comments:
          (map['comments'] as List?)
              ?.map((e) => CommentModel.fromMap(e))
              .toList(),
      createdAt: map['createdAt'],
    );
  }

  // 🆕 Tambahkan method copyWith biar bisa update sebagian field
  PostModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    bool? isLike,
    int? totalLikes,
    UserModel? user,
    List<CommentModel>? comments,
    String? createdAt,
  }) {
    return PostModel(
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
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }
}
