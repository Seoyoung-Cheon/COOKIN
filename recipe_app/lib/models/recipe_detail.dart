import 'ingredient.dart';
import 'recipe.dart';

/// 레시피 상세 정보 모델 클래스
/// Recipe 모델을 확장하여 더 상세한 정보를 포함
class RecipeDetail {
  final String id;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final int cookingTime;
  final int servingSize;
  final String? imageUrl;
  final double? rating;
  final String? difficulty;

  // 상세 정보 추가 필드
  final String? summary; // 요약 정보
  final List<String>? cuisines; // 요리 종류
  final List<String>? dishTypes; // 요리 타입
  final List<String>? diets; // 식단 타입
  final int? preparationMinutes; // 준비 시간
  final int? totalMinutes; // 총 소요 시간
  final String? sourceUrl; // 출처 URL
  final String? sourceName; // 출처 이름

  RecipeDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servingSize,
    this.imageUrl,
    this.rating,
    this.difficulty,
    this.summary,
    this.cuisines,
    this.dishTypes,
    this.diets,
    this.preparationMinutes,
    this.totalMinutes,
    this.sourceUrl,
    this.sourceName,
  });

  /// JSON에서 생성
  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
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

    return RecipeDetail(
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
      summary: json['summary']?.replaceAll(RegExp(r'<[^>]*>'), ''),
      cuisines:
          json['cuisines'] != null ? List<String>.from(json['cuisines']) : null,
      dishTypes: json['dishTypes'] != null
          ? List<String>.from(json['dishTypes'])
          : null,
      diets: json['diets'] != null ? List<String>.from(json['diets']) : null,
      preparationMinutes: json['preparationMinutes'],
      totalMinutes: json['totalMinutes'],
      sourceUrl: json['sourceUrl'],
      sourceName: json['sourceName'],
    );
  }

  static String? _getDifficulty(double? score) {
    if (score == null) return null;
    if (score >= 80) return '어려움';
    if (score >= 50) return '보통';
    return '쉬움';
  }

  /// Recipe 모델로 변환
  Recipe toRecipe() {
    return Recipe(
      id: id,
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      cookingTime: cookingTime,
      servingSize: servingSize,
      imageUrl: imageUrl,
      rating: rating,
      difficulty: difficulty,
    );
  }
}
