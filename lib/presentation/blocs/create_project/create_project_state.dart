import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  // Available icons for selection
  static const List<String> availableIcons = [
    '📋', '🚀', '💡', '⚙️', '🔥', '⚡',
    '🖼️', '🧠', '💜', '🌱', '🌻', '📐',
  ];

  const CreateProjectState({
    this.name = '',
    this.description = '',
    this.selectedIcon = '💡',
    this.selectedPaletteId = 'purple_haze',
    this.dueDate,
    this.startDate,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
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
      ];
}
