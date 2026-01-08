import 'ingredient.dart';
import '../services/translation_service.dart';

/// 레시피 모델 클래스
class Recipe {
  final String id;
  final String title;
  final String description;
  final List<Ingredient> ingredients; // 필요한 재료 목록
  final List<String> steps; // 조리 단계
  final int cookingTime; // 조리 시간 (분)
  final int servingSize; // 인분
  final String? imageUrl; // 이미지 URL
  final double? rating; // 평점
  final String? difficulty; // 난이도 (예: '쉬움', '보통', '어려움')

  // 🆕 추가: API 응답용 필드
  final int? usedIngredientCount;
  final int? missedIngredientCount;
  final List<String>? usedIngredients;
  final List<String>? missedIngredients;

  // 🆕 추가: 번역된 필드들
  String? translatedTitle;
  String? translatedDescription;
  List<String>? translatedSteps;
  List<Ingredient>? translatedIngredients;

  Recipe({
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
    // 🆕 추가
    this.usedIngredientCount,
    this.missedIngredientCount,
    this.usedIngredients,
    this.missedIngredients,
    this.translatedTitle,
    this.translatedDescription,
    this.translatedSteps,
    this.translatedIngredients,
  });

  // 🆕 추가: 매칭률 계산
  double get matchRate {
    if (usedIngredientCount == null || missedIngredientCount == null) {
      return 0.0;
    }
    int total = usedIngredientCount! + missedIngredientCount!;
    if (total == 0) return 0.0;
    return (usedIngredientCount! / total) * 100;
  }

  // 🆕 추가: 번역 메서드
  Future<void> translate() async {
    final translationService = TranslationService();
    translatedTitle = await translationService.translateToKorean(title);

    // 설명 번역 (비어있지 않은 경우만)
    if (description.isNotEmpty) {
      translatedDescription =
          await translationService.translateToKorean(description);
    }

    // 조리 단계 번역
    if (steps.isNotEmpty) {
      translatedSteps = await translationService.translateList(steps);
    }

    // 재료명 번역
    if (ingredients.isNotEmpty) {
      final ingredientNames = ingredients.map((i) => i.name).toList();
      final translatedNames =
          await translationService.translateList(ingredientNames);
      translatedIngredients = [];
      for (var i = 0;
          i < ingredients.length && i < translatedNames.length;
          i++) {
        translatedIngredients!.add(
          ingredients[i].copyWith(translatedName: translatedNames[i]),
        );
      }
    }
  }

  // 🆕 추가: 표시용 필드들 (번역본 우선)
  String get displayTitle => translatedTitle ?? title;
  String get displayDescription => translatedDescription ?? description;
  List<String> get displaySteps => translatedSteps ?? steps;
  List<Ingredient> get displayIngredients =>
      translatedIngredients ?? ingredients;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'steps': steps,
      'cookingTime': cookingTime,
      'servingSize': servingSize,
      'imageUrl': imageUrl,
      'rating': rating,
      'difficulty': difficulty,
      // 🆕 추가
      'usedIngredientCount': usedIngredientCount,
      'missedIngredientCount': missedIngredientCount,
      'usedIngredients': usedIngredients,
      'missedIngredients': missedIngredients,
    };
  }

  /// JSON에서 생성
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(), // API는 int로 올 수 있음
      title: json['title'] as String,
      description: json['description'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      steps:
          json['steps'] != null ? List<String>.from(json['steps'] as List) : [],
      cookingTime: json['cookingTime'] ?? json['readyInMinutes'] ?? 30,
      servingSize: json['servingSize'] ?? json['servings'] ?? 2,
      imageUrl: json['imageUrl'] ?? json['image'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      difficulty: json['difficulty'] as String?,
      // 🆕 추가: API 응답 처리
      usedIngredientCount: json['usedIngredientCount'],
      missedIngredientCount: json['missedIngredientCount'],
      usedIngredients: (json['usedIngredients'] as List?)
          ?.map((e) => e['name'].toString())
          .toList(),
      missedIngredients: (json['missedIngredients'] as List?)
          ?.map((e) => e['name'].toString())
          .toList(),
    );
  }

  /// 복사본 생성
  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<Ingredient>? ingredients,
    List<String>? steps,
    int? cookingTime,
    int? servingSize,
    String? imageUrl,
    double? rating,
    String? difficulty,
    // 🆕 추가
    int? usedIngredientCount,
    int? missedIngredientCount,
    List<String>? usedIngredients,
    List<String>? missedIngredients,
    String? translatedTitle,
    String? translatedDescription,
    List<String>? translatedSteps,
    List<Ingredient>? translatedIngredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookingTime: cookingTime ?? this.cookingTime,
      servingSize: servingSize ?? this.servingSize,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      difficulty: difficulty ?? this.difficulty,
      // 🆕 추가
      usedIngredientCount: usedIngredientCount ?? this.usedIngredientCount,
      missedIngredientCount:
          missedIngredientCount ?? this.missedIngredientCount,
      usedIngredients: usedIngredients ?? this.usedIngredients,
      missedIngredients: missedIngredients ?? this.missedIngredients,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedDescription:
          translatedDescription ?? this.translatedDescription,
      translatedSteps: translatedSteps ?? this.translatedSteps,
      translatedIngredients:
          translatedIngredients ?? this.translatedIngredients,
    );
  }
}
