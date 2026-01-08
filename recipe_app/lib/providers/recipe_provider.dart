import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/recipe_detail.dart'; // 🆕 추가
import '../services/api_service.dart';
import '../services/database_service.dart';

/// 레시피 상태 관리 Provider
class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  Recipe? _selectedRecipe;
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 레시피 목록 불러오기
  Future<void> loadRecipes({String? query}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _apiService.getRecipes(query: query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🆕 추가: 재료로 레시피 검색 (번역 포함)
  Future<void> searchRecipes(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _error = '재료를 추가해주세요';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _apiService.searchRecipesByIngredients(ingredients);

      // 레시피 제목 번역
      for (var recipe in _recipes) {
        await recipe.translate();
      }

      if (_recipes.isEmpty) {
        _error = '검색 결과가 없습니다';
      }
    } catch (e) {
      _error = '레시피를 불러오는데 실패했습니다: $e';
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 특정 레시피 불러오기
  Future<void> loadRecipeById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRecipe = await _apiService.getRecipeById(id);
      // 레시피 번역
      if (_selectedRecipe != null) {
        await _selectedRecipe!.translate();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🆕 추가: 레시피 상세 정보 가져오기
  Future<RecipeDetail?> getRecipeDetail(int recipeId) async {
    try {
      final recipeDetail = await _apiService.getRecipeDetail(recipeId);
      // RecipeDetail을 Recipe로 변환하여 번역
      if (recipeDetail != null) {
        final recipe = recipeDetail.toRecipe();
        await recipe.translate();
        // 번역된 내용을 RecipeDetail에 반영
        return RecipeDetail(
          id: recipe.id,
          title: recipe.title,
          description: recipe.description,
          ingredients: recipe.ingredients,
          steps: recipe.displaySteps, // 번역된 단계 사용
          cookingTime: recipe.cookingTime,
          servingSize: recipe.servingSize,
          imageUrl: recipe.imageUrl,
          rating: recipe.rating,
          difficulty: recipe.difficulty,
          summary: recipe.translatedDescription ?? recipeDetail.summary,
          cuisines: recipeDetail.cuisines,
          dishTypes: recipeDetail.dishTypes,
          diets: recipeDetail.diets,
          preparationMinutes: recipeDetail.preparationMinutes,
          totalMinutes: recipeDetail.totalMinutes,
          sourceUrl: recipeDetail.sourceUrl,
          sourceName: recipeDetail.sourceName,
        );
      }
      return recipeDetail;
    } catch (e) {
      print('Error getting recipe detail: $e');
      return null;
    }
  }

  /// 즐겨찾기 레시피 불러오기
  Future<void> loadFavoriteRecipes() async {
    try {
      _favoriteRecipes = await _databaseService.loadFavoriteRecipes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 즐겨찾기 추가
  Future<void> addFavoriteRecipe(Recipe recipe) async {
    try {
      await _databaseService.addFavoriteRecipe(recipe);
      await loadFavoriteRecipes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 즐겨찾기 제거
  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      await _databaseService.removeFavoriteRecipe(recipeId);
      await loadFavoriteRecipes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 선택된 레시피 설정
  void setSelectedRecipe(Recipe? recipe) {
    _selectedRecipe = recipe;
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 검색 결과 초기화
  void clearSearchResults() {
    _recipes = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
