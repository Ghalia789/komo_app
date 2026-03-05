import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/project.dart';

class ColorPalette extends Equatable {
  final String id;
  final String name;
  final List<Color> colors;

  const ColorPalette({
    required this.id,
    required this.name,
    required this.colors,
  });

  static const List<ColorPalette> palettes = [
    ColorPalette(
      id: 'purple_haze',
      name: 'Purple Haze',
      colors: [Color(0xFF9600BF), Color(0xFFB85C6E), Color(0xFF7D627F)],
    ),
    ColorPalette(
      id: 'ocean_depth',
      name: 'Ocean Depth',
      colors: [Color(0xFFD4A017), Color(0xFF268060), Color(0xFF3E0C54)],
    ),
    ColorPalette(
      id: 'sunset_glow',
      name: 'Sunset Glow',
      colors: [Color(0xFFE87A2D), Color(0xFFF5A8B8), Color(0xFFE6C7C2)],
    ),
    ColorPalette(
      id: 'midnight',
      name: 'Midnight',
      colors: [Color(0xFF3E0C54), Color(0xFF7D627F), Color(0xFFC4B5C8)],
    ),
  ];

  /// Maps palette id to the color string stored in Firestore.
  String get colorKey {
    switch (id) {
      case 'ocean_depth':
        return 'ocean';
      case 'sunset_glow':
        return 'sunset';
      case 'midnight':
        return 'mono';
      default:
        return 'purple';
    }
  }

  @override
  List<Object?> get props => [id, name, colors];
}

class CreateProjectState extends Equatable {
  final String name;
  final String description;
  final String selectedIcon;
  final String selectedPaletteId;
  final DateTime? dueDate;
  final DateTime? startDate;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final Project? createdProject;

  // Available icons for selection
  static const List<String> availableIcons = [
    '\u{1F4CB}', '\u{1F680}', '\u{1F4A1}', '\u2699\uFE0F', '\u{1F525}', '\u26A1',
    '\u{1F5BC}\uFE0F', '\u{1F9E0}', '\u{1F49C}', '\u{1F331}', '\u{1F33B}', '\u{1F4D0}',
  ];

  const CreateProjectState({
    this.name = '',
    this.description = '',
    this.selectedIcon = '\u{1F4A1}',
    this.selectedPaletteId = 'purple_haze',
    this.dueDate,
    this.startDate,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.createdProject,
  });

  bool get isStep1Valid => name.trim().isNotEmpty;

  ColorPalette get selectedPalette =>
      ColorPalette.palettes.firstWhere(
        (p) => p.id == selectedPaletteId,
        orElse: () => ColorPalette.palettes.first,
      );

  CreateProjectState copyWith({
    String? name,
    String? description,
    String? selectedIcon,
    String? selectedPaletteId,
    DateTime? Function()? dueDate,
    DateTime? Function()? startDate,
    bool? isLoading,
    bool? isSuccess,
    String? Function()? errorMessage,
    Project? Function()? createdProject,
  }) {
    return CreateProjectState(
      name: name ?? this.name,
      description: description ?? this.description,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      selectedPaletteId: selectedPaletteId ?? this.selectedPaletteId,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      startDate: startDate != null ? startDate() : this.startDate,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      createdProject: createdProject != null ? createdProject() : this.createdProject,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        selectedIcon,
        selectedPaletteId,
        dueDate,
        startDate,
        isLoading,
        isSuccess,
        errorMessage,
        createdProject,
      ];
}
