import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
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

  /// 특정 레시피 불러오기
  Future<void> loadRecipeById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRecipe = await _apiService.getRecipeById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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

  /// 레시피 검색
  Future<void> searchRecipes(String query) async {
    await loadRecipes(query: query);
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
}

