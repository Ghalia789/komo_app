import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project_invitation.dart';

class ProjectInvitationModel {
  const ProjectInvitationModel({
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

  factory ProjectInvitationModel.fromDomain(ProjectInvitation invitation) {
    return ProjectInvitationModel(
      id: invitation.id,
      projectId: invitation.projectId,
      invitedEmail: invitation.invitedEmail,
      invitedByUserId: invitation.invitedByUserId,
      status: invitation.status,
      createdAt: invitation.createdAt,
      updatedAt: invitation.updatedAt,
      lastSentAt: invitation.lastSentAt,
      acceptedAt: invitation.acceptedAt,
      invitedUserId: invitation.invitedUserId,
    );
  }

  ProjectInvitation toDomain() {
    return ProjectInvitation(
      id: id,
      projectId: projectId,
      invitedEmail: invitedEmail,
      invitedByUserId: invitedByUserId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSentAt: lastSentAt,
      acceptedAt: acceptedAt,
      invitedUserId: invitedUserId,
    );
  }

  factory ProjectInvitationModel.fromJson(Map<String, dynamic> json) {
    return ProjectInvitationModel(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      invitedEmail: json['invitedEmail'] as String? ?? '',
      invitedByUserId: json['invitedByUserId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: _fromTimestamp(json['updatedAt']),
      lastSentAt: _fromTimestamp(json['lastSentAt']),
      acceptedAt: _fromTimestamp(json['acceptedAt']),
      invitedUserId: json['invitedUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'invitedEmail': invitedEmail,
      'invitedByUserId': invitedByUserId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastSentAt': lastSentAt,
      'acceptedAt': acceptedAt,
      'invitedUserId': invitedUserId,
    };
  }
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}
