import 'ingredient.dart';

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
  });

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
    };
  }

  /// JSON에서 생성
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(json['steps'] as List),
      cookingTime: json['cookingTime'] as int,
      servingSize: json['servingSize'] as int,
      imageUrl: json['imageUrl'] as String?,
      rating: json['rating'] as double?,
      difficulty: json['difficulty'] as String?,
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
    );
  }
}

