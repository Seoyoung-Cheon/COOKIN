import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_pantry.dart';
import '../models/recipe.dart';

/// 로컬 데이터베이스 관리 서비스
class DatabaseService {
  static const String _pantryKey = 'user_pantry';
  static const String _favoriteRecipesKey = 'favorite_recipes';

  /// 냉장고 데이터 저장
  Future<void> savePantry(UserPantry pantry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pantryKey, json.encode(pantry.toJson()));
    } catch (e) {
      throw Exception('냉장고 데이터 저장 실패: $e');
    }
  }

  /// 냉장고 데이터 불러오기
  Future<UserPantry?> loadPantry(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pantryJson = prefs.getString(_pantryKey);

      if (pantryJson != null) {
        final data = json.decode(pantryJson);
        return UserPantry.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('냉장고 데이터 불러오기 실패: $e');
    }
  }

  /// 즐겨찾기 레시피 저장
  Future<void> saveFavoriteRecipes(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = recipes.map((r) => r.toJson()).toList();
      await prefs.setString(_favoriteRecipesKey, json.encode(recipesJson));
    } catch (e) {
      throw Exception('즐겨찾기 레시피 저장 실패: $e');
    }
  }

  /// 즐겨찾기 레시피 불러오기
  Future<List<Recipe>> loadFavoriteRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recipesJson = prefs.getString(_favoriteRecipesKey);

      if (recipesJson != null) {
        final List<dynamic> data = json.decode(recipesJson);
        return data.map((json) => Recipe.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('즐겨찾기 레시피 불러오기 실패: $e');
    }
  }

  /// 즐겨찾기 레시피 추가
  Future<void> addFavoriteRecipe(Recipe recipe) async {
    try {
      final favorites = await loadFavoriteRecipes();
      if (!favorites.any((r) => r.id == recipe.id)) {
        favorites.add(recipe);
        await saveFavoriteRecipes(favorites);
      }
    } catch (e) {
      throw Exception('즐겨찾기 추가 실패: $e');
    }
  }

  /// 즐겨찾기 레시피 제거
  Future<void> removeFavoriteRecipe(String recipeId) async {
    try {
      final favorites = await loadFavoriteRecipes();
      favorites.removeWhere((r) => r.id == recipeId);
      await saveFavoriteRecipes(favorites);
    } catch (e) {
      throw Exception('즐겨찾기 제거 실패: $e');
    }
  }

  /// 데이터 초기화
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pantryKey);
      await prefs.remove(_favoriteRecipesKey);
    } catch (e) {
      throw Exception('데이터 초기화 실패: $e');
    }
  }
}

