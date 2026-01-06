import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/cooking_timer.dart';

/// 레시피 상세 화면
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레시피 이미지 (있는 경우)
            if (recipe.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            // 레시피 정보
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            // 조리 정보
            Row(
              children: [
                _buildInfoChip(Icons.access_time, '${recipe.cookingTime}분'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.people, '${recipe.servingSize}인분'),
                if (recipe.difficulty != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.star, recipe.difficulty!),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // 필요한 재료
            const Text(
              '필요한 재료',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ingredient.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (ingredient.quantity != null && ingredient.unit != null)
                        Text(
                          '${ingredient.quantity} ${ingredient.unit}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // 조리 단계
            const Text(
              '조리 방법',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // 타이머 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CookingTimer(
                      cookingTime: recipe.cookingTime,
                    ),
                  );
                },
                icon: const Icon(Icons.timer),
                label: const Text('조리 타이머 시작'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

