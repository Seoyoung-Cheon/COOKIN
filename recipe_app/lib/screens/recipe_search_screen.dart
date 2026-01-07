import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import '../services/api_service.dart';
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
  final ApiService _apiService = ApiService();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recipes = [];
    });

    try {
      print('검색 시작 - 재료: $_selectedIngredients'); // 디버깅용
      final recipes =
          await _apiService.searchRecipesByIngredients(_selectedIngredients);
      print('검색 완료 - 레시피 수: ${recipes.length}'); // 디버깅용
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });

      if (recipes.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('검색 결과가 없습니다. 다른 재료를 시도해보세요.'),
          ),
        );
      }
    } catch (e) {
      print('검색 에러: $e'); // 디버깅용
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '레시피 검색 실패: ${e.toString().replaceAll('Exception: ', '')}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
                const SizedBox(height: 4),
                Text(
                  '※ 한글로 입력하세요 (예: 양파, 당근, 감자)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _searchRecipes,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restaurant_menu),
                    label: Text(_isLoading ? '검색 중...' : '요리하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 검색 결과 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      )
                    : _recipes.isEmpty
                        ? const Center(
                            child: Text(
                              '재료를 추가하고 "요리하기" 버튼을 눌러주세요.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _recipes[index];
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
                          ),
          ),
        ],
      ),
    );
  }
}
