import 'ingredient.dart';

/// 사용자 냉장고 모델 클래스
class UserPantry {
  final String userId;
  final List<Ingredient> ingredients; // 냉장고에 있는 재료들

  UserPantry({
    required this.userId,
    required this.ingredients,
  });

  /// 재료 추가
  void addIngredient(Ingredient ingredient) {
    ingredients.add(ingredient);
  }

  /// 재료 제거
  void removeIngredient(String ingredientId) {
    ingredients.removeWhere((ingredient) => ingredient.id == ingredientId);
  }

  /// 재료 찾기
  Ingredient? findIngredient(String ingredientId) {
    try {
      return ingredients.firstWhere((ingredient) => ingredient.id == ingredientId);
    } catch (e) {
      return null;
    }
  }

  /// 카테고리별 재료 필터링
  List<Ingredient> getIngredientsByCategory(String category) {
    return ingredients.where((ingredient) => ingredient.category == category).toList();
  }

  /// 유통기한 임박 재료 필터링
  List<Ingredient> getExpiringSoon({int days = 3}) {
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: days));
    return ingredients.where((ingredient) {
      if (ingredient.expiryDate == null) return false;
      return ingredient.expiryDate!.isBefore(expiryDate) &&
          ingredient.expiryDate!.isAfter(now);
    }).toList();
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }

  /// JSON에서 생성
  factory UserPantry.fromJson(Map<String, dynamic> json) {
    return UserPantry(
      userId: json['userId'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}



