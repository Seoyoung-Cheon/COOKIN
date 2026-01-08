/// 재료 모델 클래스
class Ingredient {
  final String id;
  final String name;
  final String? unit; // 단위 (예: 'g', 'ml', '개')
  final double? quantity; // 수량
  final DateTime? expiryDate; // 유통기한
  final String? category; // 카테고리 (예: '채소', '육류', '유제품')

  // 번역된 이름
  String? translatedName;

  Ingredient({
    required this.id,
    required this.name,
    this.unit,
    this.quantity,
    this.expiryDate,
    this.category,
    this.translatedName,
  });

  // 표시용 이름 (번역본 우선)
  String get displayName => translatedName ?? name;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'expiryDate': expiryDate?.toIso8601String(),
      'category': category,
    };
  }

  /// JSON에서 생성
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String?,
      quantity: json['quantity'] as double?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      category: json['category'] as String?,
    );
  }

  /// 복사본 생성
  Ingredient copyWith({
    String? id,
    String? name,
    String? unit,
    double? quantity,
    DateTime? expiryDate,
    String? category,
    String? translatedName,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      translatedName: translatedName ?? this.translatedName,
    );
  }
}
