import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../utils/constants.dart';
import '../utils/ingredient_translator.dart';

/// 외부 API 호출 서비스
class ApiService {
  static const String baseUrl = ApiConstants.spoonacularBaseUrl;
  static const String apiKey = ApiConstants.spoonacularApiKey;

  /// 레시피 목록 가져오기
  Future<List<Recipe>> getRecipes({String? query}) async {
    try {
      final url =
          Uri.parse('$baseUrl/recipes${query != null ? '?q=$query' : ''}');
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

  /// 특정 레시피 가져오기 (Spoonacular API)
  Future<Recipe> getRecipeById(String id) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/$id/information?apiKey=$apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _recipeFromSpoonacularJson(data);
      } else {
        final errorBody = response.body;
        print('레시피 상세 정보 가져오기 실패: $errorBody'); // 디버깅용
        throw Exception('레시피를 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      print('레시피 상세 정보 API 호출 에러: $e'); // 디버깅용
      throw Exception('네트워크 오류: $e');
    }
  }

  /// Spoonacular API 응답을 Recipe 모델로 변환
  Recipe _recipeFromSpoonacularJson(Map<String, dynamic> json) {
    // 재료 목록 파싱
    final List<Ingredient> ingredients = [];
    if (json['extendedIngredients'] != null) {
      final extendedIngredients = json['extendedIngredients'] as List;
      for (var item in extendedIngredients) {
        ingredients.add(Ingredient(
          id: item['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: item['name'] ?? item['nameClean'] ?? '',
          unit: item['unit'],
          quantity: item['amount']?.toDouble(),
        ));
      }
    }

    // 조리 단계 파싱
    final List<String> steps = [];
    if (json['analyzedInstructions'] != null &&
        json['analyzedInstructions'].isNotEmpty) {
      final instructions = json['analyzedInstructions'][0];
      if (instructions['steps'] != null) {
        for (var step in instructions['steps']) {
          steps.add(step['step'] ?? '');
        }
      }
    }

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '레시피',
      description: json['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
      ingredients: ingredients,
      steps: steps,
      cookingTime: json['readyInMinutes'] ?? 0,
      servingSize: json['servings'] ?? 1,
      imageUrl: json['image'],
      rating: json['spoonacularScore']?.toDouble(),
      difficulty: _getDifficulty(json['spoonacularScore']?.toDouble()),
    );
  }

  String? _getDifficulty(double? score) {
    if (score == null) return null;
    if (score >= 80) return '어려움';
    if (score >= 50) return '보통';
    return '쉬움';
  }

  /// 재료로 레시피 검색 (Spoonacular API)
  Future<List<Recipe>> searchRecipesByIngredients(
      List<String> ingredientNames) async {
    try {
      // 한글 재료명을 영어로 변환
      final englishNames = IngredientTranslator.translateList(ingredientNames);

      print('원본 재료: $ingredientNames'); // 디버깅용
      print('변환된 재료: $englishNames'); // 디버깅용

      // 재료 이름들을 쉼표로 구분하여 연결 (공백 제거 및 URL 인코딩)
      final ingredientsString = englishNames
          .map((name) => Uri.encodeComponent(name.trim()))
          .join(',');

      final url = Uri.parse(
        '$baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&apiKey=$apiKey&number=10',
      );

      print('API 호출 URL: $url'); // 디버깅용

      final response = await http.get(url);

      print('API 응답 상태 코드: ${response.statusCode}'); // 디버깅용
      print(
          'API 응답 본문: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}'); // 디버깅용

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          throw Exception('검색 결과가 없습니다. 다른 재료를 시도해보세요.');
        }

        print('검색된 레시피 수: ${data.length}'); // 디버깅용

        final List<Recipe> recipes = [];

        // 각 레시피의 상세 정보를 가져옴 (최대 5개만 상세 정보 가져오기 - 성능 개선)
        for (var i = 0; i < data.length && i < 5; i++) {
          final item = data[i];
          final recipeId = item['id'].toString();
          try {
            print('레시피 상세 정보 가져오는 중: $recipeId'); // 디버깅용
            final recipe = await getRecipeById(recipeId);
            recipes.add(recipe);
          } catch (e) {
            print('레시피 상세 정보 가져오기 실패: $e'); // 디버깅용
            // 상세 정보를 가져오지 못한 경우 간단한 정보만 사용
            recipes.add(Recipe(
              id: recipeId,
              title: item['title'] ?? '레시피',
              description: '',
              ingredients: [],
              steps: [],
              cookingTime: 0,
              servingSize: 1,
              imageUrl: item['image'],
            ));
          }
        }

        // 나머지 레시피는 간단한 정보만 사용
        for (var i = 5; i < data.length; i++) {
          final item = data[i];
          recipes.add(Recipe(
            id: item['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: item['title'] ?? '레시피',
            description: '',
            ingredients: [],
            steps: [],
            cookingTime: 0,
            servingSize: 1,
            imageUrl: item['image'],
          ));
        }

        print('최종 레시피 수: ${recipes.length}'); // 디버깅용
        return recipes;
      } else {
        final errorBody = response.body;
        print('API 에러 응답: $errorBody'); // 디버깅용
        throw Exception(
            '레시피 검색에 실패했습니다. (상태 코드: ${response.statusCode})\n$errorBody');
      }
    } catch (e) {
      print('API 호출 에러: $e'); // 디버깅용
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
