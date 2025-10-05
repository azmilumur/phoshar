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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.updatedAt,
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
      comments: map['comments'] != null
          ? (map['comments'] as List)
              .map((c) => CommentModel.fromMap(c))
              .toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
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
