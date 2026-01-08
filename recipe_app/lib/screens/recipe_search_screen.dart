import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/recipe_card.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

/// 레시피 찾기 화면
class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final List<String> _selectedIngredients = [];

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 검색 결과 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeProvider =
          Provider.of<RecipeProvider>(context, listen: false);
      recipeProvider.clearSearchResults();
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  /// 재료 추가
  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  /// 재료 제거
  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
  }

  /// 레시피 검색
  Future<void> _searchRecipes() async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 하나 이상 추가해주세요.')),
      );
      return;
    }

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    await recipeProvider.searchRecipes(_selectedIngredients);

    if (recipeProvider.recipes.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('검색 결과가 없습니다. 다른 재료를 시도해보세요.'),
        ),
      );
    }

    if (recipeProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recipeProvider.error!),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 찾기'),
      ),
      body: Column(
        children: [
          // 재료 입력 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '음식 재료를 입력하세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ingredientController,
                        decoration: const InputDecoration(
                          hintText: '예: 양파, 당근, 감자, 닭고기',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('추가'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 선택된 재료 라벨들
                if (_selectedIngredients.isNotEmpty) ...[
                  const Text(
                    '선택한 재료:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedIngredients.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeIngredient(ingredient),
                        backgroundColor: Colors.orange[50],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                // 요리하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: Consumer<RecipeProvider>(
                    builder: (context, recipeProvider, child) {
                      return ElevatedButton.icon(
                        onPressed:
                            recipeProvider.isLoading ? null : _searchRecipes,
                        icon: recipeProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.restaurant_menu),
                        label:
                            Text(recipeProvider.isLoading ? '검색 중...' : '요리하기'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 검색 결과 영역
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, child) {
                if (recipeProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 로딩 애니메이션
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepOrange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 로딩 텍스트
                        Text(
                          '레시피를 찾고 있어요...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '잠시만 기다려주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (recipeProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          recipeProvider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (recipeProvider.recipes.isEmpty) {
                  return const Center(
                    child: Text(
                      '재료를 추가하고 "요리하기" 버튼을 눌러주세요.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipeProvider.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipeProvider.recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
