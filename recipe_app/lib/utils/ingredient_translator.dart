/// 한글 재료명을 영어로 변환하는 유틸리티
class IngredientTranslator {
  // 한글-영어 재료명 매핑
  static final Map<String, String> _ingredientMap = {
    // 채소류
    '양파': 'onion',
    '당근': 'carrot',
    '감자': 'potato',
    '토마토': 'tomato',
    '마늘': 'garlic',
    '파': 'green onion',
    '대파': 'scallion',
    '쪽파': 'chive',
    '상추': 'lettuce',
    '배추': 'cabbage',
    '양배추': 'cabbage',
    '시금치': 'spinach',
    '브로콜리': 'broccoli',
    '콜리플라워': 'cauliflower',
    '오이': 'cucumber',
    '가지': 'eggplant',
    '호박': 'zucchini',
    '애호박': 'zucchini',
    '고추': 'pepper',
    '청고추': 'green pepper',
    '빨간고추': 'red pepper',
    '피망': 'bell pepper',
    '파프리카': 'bell pepper',
    '버섯': 'mushroom',
    '팽이버섯': 'enoki mushroom',
    '표고버섯': 'shiitake mushroom',
    '새송이버섯': 'king oyster mushroom',
    '인삼': 'ginseng',
    '생강': 'ginger',
    '고구마': 'sweet potato',
    '옥수수': 'corn',
    '콩': 'bean',
    '완두콩': 'pea',
    '강낭콩': 'kidney bean',
    '팥': 'red bean',
    '콩나물': 'bean sprout',
    '숙주나물': 'mung bean sprout',
    '미나리': 'water dropwort',
    '깻잎': 'perilla leaf',
    '쑥갓': 'crown daisy',
    '아욱': 'mallow',
    '부추': 'chive',
    '달래': 'wild chive',
    '두릅': 'aralia',
    '고사리': 'fern',
    '도라지': 'balloon flower',
    '취나물': 'aster',
    '냉이': 'shepherd\'s purse',
    '열무': 'young radish',
    '무': 'radish',
    '배추김치': 'kimchi',
    '김치': 'kimchi',

    // 육류
    '소고기': 'beef',
    '돼지고기': 'pork',
    '닭고기': 'chicken',
    '닭': 'chicken',
    '오리': 'duck',
    '양고기': 'lamb',
    '베이컨': 'bacon',
    '햄': 'ham',
    '소시지': 'sausage',
    '돼지갈비': 'pork ribs',
    '소갈비': 'beef ribs',
    '삼겹살': 'pork belly',
    '목살': 'pork neck',
    '안심': 'tenderloin',
    '등심': 'sirloin',
    '갈비살': 'ribeye',
    '치킨': 'chicken',
    '닭다리': 'chicken leg',
    '닭가슴살': 'chicken breast',
    '닭날개': 'chicken wing',

    // 해산물
    '생선': 'fish',
    '연어': 'salmon',
    '참치': 'tuna',
    '고등어': 'mackerel',
    '꽁치': 'saury',
    '멸치': 'anchovy',
    '새우': 'shrimp',
    '게': 'crab',
    '대게': 'king crab',
    '꽃게': 'blue crab',
    '랍스터': 'lobster',
    '오징어': 'squid',
    '문어': 'octopus',
    '전복': 'abalone',
    '굴': 'oyster',
    '홍합': 'mussel',
    '조개': 'clam',
    '바지락': 'short neck clam',
    '소라': 'whelk',
    '해삼': 'sea cucumber',
    '멍게': 'sea squirt',
    '미역': 'seaweed',
    '김': 'seaweed',
    '다시마': 'kelp',
    '미역줄기': 'seaweed stem',

    // 유제품/계란
    '계란': 'egg',
    '달걀': 'egg',
    '우유': 'milk',
    '치즈': 'cheese',
    '모짜렐라': 'mozzarella',
    '체다치즈': 'cheddar cheese',
    '크림치즈': 'cream cheese',
    '버터': 'butter',
    '마가린': 'margarine',
    '생크림': 'whipping cream',
    '요구르트': 'yogurt',
    '요거트': 'yogurt',

    // 곡물/면류
    '쌀': 'rice',
    '밥': 'rice',
    '국수': 'noodle',
    '라면': 'ramen',
    '스파게티': 'spaghetti',
    '파스타': 'pasta',
    '면': 'noodle',
    '소면': 'thin noodle',
    '우동': 'udon',
    '당면': 'glass noodle',
    '떡': 'rice cake',
    '떡볶이떡': 'rice cake',
    '밀가루': 'flour',
    '강력분': 'bread flour',
    '박력분': 'cake flour',
    '빵': 'bread',
    '식빵': 'white bread',
    '토스트': 'toast',

    // 조미료/양념
    '소금': 'salt',
    '설탕': 'sugar',
    '후추': 'pepper',
    '검은후추': 'black pepper',
    '고춧가루': 'red pepper powder',
    '고추장': 'gochujang',
    '된장': 'doenjang',
    '간장': 'soy sauce',
    '식초': 'vinegar',
    '올리브오일': 'olive oil',
    '식용유': 'cooking oil',
    '참기름': 'sesame oil',
    '들기름': 'perilla oil',
    '마요네즈': 'mayonnaise',
    '케첩': 'ketchup',
    '겨자': 'mustard',
    '와사비': 'wasabi',
    '꿀': 'honey',
    '물엿': 'corn syrup',
    '올리고당': 'oligosaccharide',
    '다진마늘': 'minced garlic',
    '생강즙': 'ginger juice',
    '파슬리': 'parsley',
    '바질': 'basil',
    '로즈마리': 'rosemary',
    '타임': 'thyme',
    '오레가노': 'oregano',
    '카레가루': 'curry powder',
    '카레': 'curry',
    '커리': 'curry',

    // 과일
    '사과': 'apple',
    '배': 'pear',
    '딸기': 'strawberry',
    '바나나': 'banana',
    '오렌지': 'orange',
    '레몬': 'lemon',
    '라임': 'lime',
    '포도': 'grape',
    '수박': 'watermelon',
    '참외': 'oriental melon',
    '멜론': 'melon',
    '복숭아': 'peach',
    '자두': 'plum',
    '체리': 'cherry',
    '키위': 'kiwi',
    '파인애플': 'pineapple',
    '망고': 'mango',
    '아보카도': 'avocado',

    // 견과류
    '땅콩': 'peanut',
    '호두': 'walnut',
    '아몬드': 'almond',
    '잣': 'pine nut',
    '은행': 'gingko nut',
    '밤': 'chestnut',
    '캐슈넛': 'cashew',

    // 기타
    '두부': 'tofu',
    '순두부': 'soft tofu',
    '시래기': 'dried radish leaves',
    '건표고': 'dried shiitake',
    '건미역': 'dried seaweed',
    '멸치다시마': 'anchovy kelp',
  };

  /// 한글 재료명을 영어로 변환
  /// 변환할 수 없으면 원래 입력값을 반환
  static String translateToEnglish(String koreanName) {
    // 공백 제거 및 소문자 변환
    final trimmed = koreanName.trim();

    // 정확히 일치하는 경우
    if (_ingredientMap.containsKey(trimmed)) {
      return _ingredientMap[trimmed]!;
    }

    // 부분 일치 검색 (예: "양파 1개" -> "양파" 찾기)
    for (var key in _ingredientMap.keys) {
      if (trimmed.contains(key)) {
        return _ingredientMap[key]!;
      }
    }

    // 변환할 수 없으면 원래 값 반환 (영어로 입력한 경우 대비)
    return trimmed;
  }

  /// 여러 재료명을 한번에 변환
  static List<String> translateList(List<String> koreanNames) {
    return koreanNames.map((name) => translateToEnglish(name)).toList();
  }
}
