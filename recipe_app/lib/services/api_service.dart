import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/recipe_detail.dart';
import '../models/ingredient.dart';
import '../utils/constants.dart';
import '../utils/ingredient_translator.dart';

/// 외부 API 호출 서비스
class ApiService {
  static const String baseUrl = ApiConstants.spoonacularBaseUrl;
  static const String apiKey = ApiConstants.spoonacularApiKey;

  // 🆕 한국인이 좋아할 만한 요리 태그
  final List<String> _koreanFriendlyTags = [
    'asian',
    'korean',
    'japanese',
    'chinese',
    'soup',
    'rice',
    'noodles',
    'stir fry',
    'fried',
    'boiled',
  ];

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

  /// 한국인이 좋아할 만한 요리인지 확인
  bool _isKoreanFriendly(RecipeDetail recipeDetail) {
    // cuisines 확인
    if (recipeDetail.cuisines != null) {
      for (var cuisine in recipeDetail.cuisines!) {
        final lowerCuisine = cuisine.toLowerCase();
        if (_koreanFriendlyTags.any((tag) => lowerCuisine.contains(tag))) {
          return true;
        }
      }
    }

    // dishTypes 확인
    if (recipeDetail.dishTypes != null) {
      for (var dishType in recipeDetail.dishTypes!) {
        final lowerDishType = dishType.toLowerCase();
        if (_koreanFriendlyTags.any((tag) => lowerDishType.contains(tag))) {
          return true;
        }
      }
    }

    // 제목 확인 (한국인이 좋아할 만한 키워드 포함 여부)
    final lowerTitle = recipeDetail.title.toLowerCase();
    if (_koreanFriendlyTags.any((tag) => lowerTitle.contains(tag))) {
      return true;
    }

    return false;
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
        int checkedCount = 0;
        const int maxRecipes = 10; // 최대 10개의 한식 레시피
        const int maxCheck = 30; // 최대 30개까지 확인

        // 한식 레시피만 필터링하여 가져오기
        for (var i = 0;
            i < data.length &&
                recipes.length < maxRecipes &&
                checkedCount < maxCheck;
            i++) {
          final item = data[i];
          final recipeId = item['id'].toString();
          checkedCount++;

          try {
            print('레시피 상세 정보 가져오는 중: $recipeId'); // 디버깅용
            final recipeDetail = await getRecipeDetail(int.parse(recipeId));

            if (recipeDetail != null) {
              // 한국인이 좋아할 만한 요리인지 확인
              final isKoreanFriendly = _isKoreanFriendly(recipeDetail);

              if (isKoreanFriendly) {
                // 한국인이 좋아할 만한 요리인 경우 추가
                final recipe = recipeDetail.toRecipe();
                recipes.add(recipe);
                print('한국인 선호 레시피 추가: ${recipe.title}'); // 디버깅용
              } else {
                print('한국인 선호가 아닌 레시피 건너뜀: ${recipeDetail.title}'); // 디버깅용
              }
            }
          } catch (e) {
            print('레시피 상세 정보 가져오기 실패: $e'); // 디버깅용
            // 에러 발생 시 건너뛰기
            continue;
          }
        }

        // 한식 레시피가 충분하지 않으면 추가로 검색
        if (recipes.length < 5 && data.length < maxCheck) {
          // 더 많은 결과를 가져오기 위해 number 파라미터 증가
          final extendedUrl = Uri.parse(
            '$baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&apiKey=$apiKey&number=30',
          );

          try {
            final extendedResponse = await http.get(extendedUrl);
            if (extendedResponse.statusCode == 200) {
              final List<dynamic> extendedData =
                  json.decode(extendedResponse.body);

              // 이미 확인한 레시피 ID 목록
              final checkedIds =
                  data.map((item) => item['id'].toString()).toSet();

              for (var item in extendedData) {
                if (recipes.length >= maxRecipes) break;

                final recipeId = item['id'].toString();
                if (checkedIds.contains(recipeId)) continue; // 이미 확인한 레시피는 건너뛰기

                try {
                  final recipeDetail =
                      await getRecipeDetail(int.parse(recipeId));
                  if (recipeDetail != null) {
                    final isKoreanFriendly = _isKoreanFriendly(recipeDetail);

                    if (isKoreanFriendly) {
                      final recipe = recipeDetail.toRecipe();
                      recipes.add(recipe);
                      print('추가 한국인 선호 레시피: ${recipe.title}'); // 디버깅용
                    }
                  }
                } catch (e) {
                  continue;
                }
              }
            }
          } catch (e) {
            print('추가 검색 실패: $e'); // 디버깅용
          }
        }

        if (recipes.isEmpty) {
          throw Exception('한국인 선호 레시피를 찾을 수 없습니다. 다른 재료를 시도해보세요.');
        }

        print('최종 한국인 선호 레시피 수: ${recipes.length}'); // 디버깅용
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

  /// 레시피 상세 정보 가져오기 (RecipeDetail 반환)
  Future<RecipeDetail?> getRecipeDetail(int recipeId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/$recipeId/information?apiKey=$apiKey',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecipeDetail.fromJson(data);
      } else {
        final errorBody = response.body;
        print('레시피 상세 정보 가져오기 실패: $errorBody');
        return null;
      }
    } catch (e) {
      print('레시피 상세 정보 API 호출 에러: $e');
      return null;
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
