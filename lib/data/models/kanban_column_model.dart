class KanbanColumnModel {
  final String id;
  final String title;
  final int taskCount;

  KanbanColumnModel({
    required this.id,
    required this.title,
    required this.taskCount,
  });

  // Mock columns
  static List<KanbanColumnModel> getMockColumns() {
    return [
      KanbanColumnModel(
        id: 'todo',
        title: 'À faire',
        taskCount: 5,
      ),
      KanbanColumnModel(
        id: 'in_progress',
        title: 'En cours',
        taskCount: 4,
      ),
      KanbanColumnModel(
        id: 'done',
        title: 'Terminé',
        taskCount: 3,
      ),
    ];
  }
}
