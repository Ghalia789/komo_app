import 'package:equatable/equatable.dart';

/// Comment entity representing a comment in the domain layer.
/// This is a pure business object without Firebase/API concerns.
class Comment extends Equatable {
  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates an empty comment
  factory Comment.empty() => Comment(
        id: '',
        taskId: '',
        authorId: '',
        authorName: '',
        text: '',
        createdAt: DateTime.now(),
      );

  /// Check if comment is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Human-readable time ago text
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if comment was edited
  bool get isEdited => updatedAt != null && updatedAt != createdAt;

  Comment copyWith({
    String? id,
    String? taskId,
    String? authorId,
    String? authorName,
    String? Function()? authorPhotoUrl,
    String? text,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl:
          authorPhotoUrl != null ? authorPhotoUrl() : this.authorPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        authorId,
        authorName,
        authorPhotoUrl,
        text,
        createdAt,
        updatedAt,
      ];
}
