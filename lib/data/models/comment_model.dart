import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

class CommentModel {
  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommentModel.fromDomain(Comment comment) => CommentModel(
        id: comment.id,
        taskId: comment.taskId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        authorPhotoUrl: comment.authorPhotoUrl,
        text: comment.text,
        createdAt: comment.createdAt,
        updatedAt: comment.updatedAt,
      );

  Comment toDomain() => Comment(
        id: id,
        taskId: taskId,
        authorId: authorId,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        text: text,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String? ?? '',
        taskId: json['taskId'] as String? ?? '',
        authorId: json['authorId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? '',
        authorPhotoUrl: json['authorPhotoUrl'] as String?,
        text: json['text'] as String? ?? '',
        createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: _fromTimestamp(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'authorId': authorId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'text': text,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

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

  // Mock comments
  static List<CommentModel> getMockComments() {
    return [
      CommentModel(
        id: '1',
        taskId: '1',
        authorId: '1',
        authorName: 'Sarah Chen',
        authorPhotoUrl: null,
        text: 'Looking great! Can we adjust the spacing on the hero section?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommentModel(
        id: '2',
        taskId: '1',
        authorId: '2',
        authorName: 'Mike Johnson',
        authorPhotoUrl: null,
        text: 'Agreed. Also, let\'s make sure the color contrast meets accessibility standards.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      CommentModel(
        id: '3',
        taskId: '1',
        authorId: '3',
        authorName: 'Emma Davis',
        authorPhotoUrl: null,
        text: 'I\'ve updated the mockup with the new brand colors. Please review!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}
