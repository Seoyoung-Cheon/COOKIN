import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();

  // 영어 → 한국어 번역
  Future<String> translateToKorean(String text) async {
    try {
      var translation = await translator.translate(
        text,
        from: 'en',
        to: 'ko',
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text; // 실패하면 원문 반환
    }
  }

  // 여러 문장 한번에 번역
  Future<List<String>> translateList(List<String> texts) async {
    List<String> translated = [];
    for (var text in texts) {
      translated.add(await translateToKorean(text));
    }
    return translated;
  }
}
