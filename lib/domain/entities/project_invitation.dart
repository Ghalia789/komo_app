import 'package:equatable/equatable.dart';

class ProjectInvitation extends Equatable {
  const ProjectInvitation({
    required this.id,
    required this.projectId,
    required this.invitedEmail,
    required this.invitedByUserId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.lastSentAt,
    this.acceptedAt,
    this.invitedUserId,
  });

  final String id;
  final String projectId;
  final String invitedEmail;
  final String invitedByUserId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSentAt;
  final DateTime? acceptedAt;
  final String? invitedUserId;

  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        id,
        projectId,
        invitedEmail,
        invitedByUserId,
        status,
        createdAt,
        updatedAt,
        lastSentAt,
        acceptedAt,
        invitedUserId,
      ];
}
