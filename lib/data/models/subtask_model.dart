class SubtaskModel {
  final String id;
  final String title;
  final bool isCompleted;

  SubtaskModel({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  SubtaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Mock subtasks for a task
  static List<SubtaskModel> getMockSubtasks() {
    return [
      SubtaskModel(
        id: '1',
        title: 'Create hero section mockup',
        isCompleted: true,
      ),
      SubtaskModel(
        id: '2',
        title: 'Design navigation bar',
        isCompleted: true,
      ),
      SubtaskModel(
        id: '3',
        title: 'Design footer layout',
        isCompleted: true,
      ),
      SubtaskModel(
        id: '4',
        title: 'Create color palette',
        isCompleted: true,
      ),
      SubtaskModel(
        id: '5',
        title: 'Design features section',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '6',
        title: 'Create testimonials layout',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '7',
        title: 'Design CTA buttons',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '8',
        title: 'Mobile responsive design',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '9',
        title: 'Create hover states',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '10',
        title: 'Design loading states',
        isCompleted: false,
      ),
      SubtaskModel(
        id: '11',
        title: 'Create error states',
        isCompleted: false,
      ),
    ];
  }
}
