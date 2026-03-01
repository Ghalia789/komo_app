import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

/// Data model for Firestore user documents with mappers to the domain [User].
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? jobTitle;
  final String? company;
  final String? role;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.jobTitle,
    this.company,
    this.role,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Map a domain entity to a data model (for persistence/transport).
  factory UserModel.fromDomain(User user) => UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        jobTitle: user.jobTitle,
        company: user.company,
        role: user.role,
        avatarUrl: user.avatarUrl,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );

  /// Map Firestore/JSON to model.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        jobTitle: json['jobTitle'] as String?,
        company: json['company'] as String?,
        role: json['role'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: _fromTimestamp(json['createdAt']) ?? DateTime.now(),
        updatedAt: _fromTimestamp(json['updatedAt']),
      );

  /// Convert to domain entity.
  User toDomain() => User(
        id: id,
        email: email,
        name: name,
        jobTitle: jobTitle,
        company: company,
        role: role,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Serialize for Firestore/JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'jobTitle': jobTitle,
        'company': company,
        'role': role,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

DateTime? _fromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  return null;
}