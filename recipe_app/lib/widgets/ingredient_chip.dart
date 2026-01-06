import 'package:flutter/material.dart';
import '../models/ingredient.dart';

/// 재료 칩 위젯
class IngredientChip extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onDeleted;
  final bool isSelected;

  const IngredientChip({
    super.key,
    required this.ingredient,
    this.onDeleted,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: isSelected ? Colors.green : Colors.grey,
        child: Icon(
          isSelected ? Icons.check : Icons.food_bank,
          size: 18,
          color: Colors.white,
        ),
      ),
      label: Text(ingredient.name),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 18) : null,
      onDeleted: onDeleted,
      backgroundColor: isSelected ? Colors.green[50] : null,
    );
  }
}

