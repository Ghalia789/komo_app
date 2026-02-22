class CommentModel {
  final String id;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
  });

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
        authorName: 'Sarah Chen',
        authorPhotoUrl: null,
        text: 'Looking great! Can we adjust the spacing on the hero section?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommentModel(
        id: '2',
        authorName: 'Mike Johnson',
        authorPhotoUrl: null,
        text: 'Agreed. Also, let\'s make sure the color contrast meets accessibility standards.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      CommentModel(
        id: '3',
        authorName: 'Emma Davis',
        authorPhotoUrl: null,
        text: 'I\'ve updated the mockup with the new brand colors. Please review!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
  }
}
