// lib/features/post/domain/comment_model.dart
class CommentModel {
  final String id;
  final String comment;
  final String username;
  final String? profilePictureUrl;

  CommentModel({
    required this.id,
    required this.comment,
    required this.username,
    this.profilePictureUrl,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      comment: map['comment'] ?? '',
      username: map['user']?['username'] ?? 'Unknown',
      profilePictureUrl: map['user']?['profilePictureUrl'] ?? '',
    );
  }
}
