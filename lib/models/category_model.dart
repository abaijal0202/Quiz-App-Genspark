import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final Color color;
  int questionCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    this.questionCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['icon'] as String,
      color: _parseColor(json['color'] as String),
    );
  }

  static Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  IconData get icon {
    switch (iconName) {
      case 'calculate':
        return Icons.calculate_outlined;
      case 'menu_book':
        return Icons.menu_book_outlined;
      case 'spellcheck':
        return Icons.spellcheck;
      case 'auto_stories':
        return Icons.auto_stories_outlined;
      case 'science':
        return Icons.science_outlined;
      case 'public':
        return Icons.public_outlined;
      default:
        return Icons.quiz_outlined;
    }
  }
}
