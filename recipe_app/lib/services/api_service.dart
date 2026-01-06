import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/ingredient.dart';

/// 외부 API 호출 서비스
class ApiService {
  // 실제 API 엔드포인트로 변경 필요
  static const String baseUrl = 'https://api.example.com';

  /// 레시피 목록 가져오기
  Future<List<Recipe>> getRecipes({String? query}) async {
    try {
      final url = Uri.parse('$baseUrl/recipes${query != null ? '?q=$query' : ''}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('레시피를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      // 에러 처리
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 특정 레시피 가져오기
  Future<Recipe> getRecipeById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/recipes/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Recipe.fromJson(data);
      } else {
        throw Exception('레시피를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 재료로 레시피 검색
  Future<List<Recipe>> searchRecipesByIngredients(List<Ingredient> ingredients) async {
    try {
      final ingredientIds = ingredients.map((i) => i.id).toList();
      final url = Uri.parse('$baseUrl/recipes/search');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ingredients': ingredientIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('레시피 검색에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 레시피 생성
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      final url = Uri.parse('$baseUrl/recipes');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Recipe.fromJson(data);
      } else {
        throw Exception('레시피 생성에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}

