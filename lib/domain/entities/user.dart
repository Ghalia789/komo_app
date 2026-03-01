import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer.
/// This is a pure business object without Firebase/API concerns.
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? jobTitle;
  final String? company;
  final String? role;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
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

  /// Creates an empty user (for initial state)
  factory User.empty() => User(
        id: '',
        email: '',
        name: '',
        createdAt: DateTime.now(),
      );

  /// Check if user is empty/not loaded
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Get initials for avatar display
  String get initials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? Function()? jobTitle,
    String? Function()? company,
    String? Function()? role,
    String? Function()? avatarUrl,
    DateTime? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      jobTitle: jobTitle != null ? jobTitle() : this.jobTitle,
      company: company != null ? company() : this.company,
      role: role != null ? role() : this.role,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        jobTitle,
        company,
        role,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}
