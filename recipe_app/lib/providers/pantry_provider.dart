import 'package:flutter/foundation.dart';
import '../models/user_pantry.dart';
import '../models/ingredient.dart';
import '../services/database_service.dart';

/// 냉장고 상태 관리 Provider
class PantryProvider with ChangeNotifier {
  UserPantry? _pantry;
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  String? _error;

  UserPantry? get pantry => _pantry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Ingredient> get ingredients => _pantry?.ingredients ?? [];

  /// 냉장고 초기화
  Future<void> initializePantry(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pantry = await _databaseService.loadPantry(userId) ??
          UserPantry(userId: userId, ingredients: []);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 재료 추가
  Future<void> addIngredient(Ingredient ingredient) async {
    if (_pantry == null) return;

    _pantry!.addIngredient(ingredient);
    notifyListeners();

    try {
      await _databaseService.savePantry(_pantry!);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // 롤백
      _pantry!.removeIngredient(ingredient.id);
      notifyListeners();
    }
  }

  /// 재료 제거
  Future<void> removeIngredient(String ingredientId) async {
    if (_pantry == null) return;

    _pantry!.removeIngredient(ingredientId);
    notifyListeners();

    try {
      await _databaseService.savePantry(_pantry!);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 카테고리별 재료 필터링
  List<Ingredient> getIngredientsByCategory(String category) {
    return _pantry?.getIngredientsByCategory(category) ?? [];
  }

  /// 유통기한 임박 재료 가져오기
  List<Ingredient> getExpiringSoon({int days = 3}) {
    return _pantry?.getExpiringSoon(days: days) ?? [];
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
