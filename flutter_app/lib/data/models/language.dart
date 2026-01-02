import 'package:freezed_annotation/freezed_annotation.dart';

part 'language.freezed.dart';
part 'language.g.dart';

@freezed
class Language with _$Language {
  const factory Language({
    required String code,
    required String name,
    required String nativeName,
    @Default('') String flag,
    @Default([]) List<String> voiceProfiles,
  }) = _Language;

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}

// Predefined languages
class Languages {
  static const english = Language(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
    voiceProfiles: ['en-US-JennyNeural', 'en-US-GuyNeural'],
  );

  static const spanish = Language(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    voiceProfiles: ['es-ES-ElviraNeural'],
  );

  static const french = Language(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
    voiceProfiles: ['fr-FR-DeniseNeural'],
  );

  static const german = Language(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
    voiceProfiles: ['de-DE-KatjaNeural'],
  );

  static const chinese = Language(
    code: 'zh',
    name: 'Chinese',
    nativeName: '中文',
    flag: '🇨🇳',
    voiceProfiles: ['zh-CN-XiaoxiaoNeural'],
  );

  static const japanese = Language(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
    voiceProfiles: ['ja-JP-NanamiNeural'],
  );

  static const korean = Language(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flag: '🇰🇷',
    voiceProfiles: ['ko-KR-SunHiNeural'],
  );

  static const arabic = Language(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    voiceProfiles: ['ar-SA-ZariyahNeural'],
  );

  static const portuguese = Language(
    code: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flag: '🇵🇹',
    voiceProfiles: ['pt-PT-RaquelNeural'],
  );

  static const russian = Language(
    code: 'ru',
    name: 'Russian',
    nativeName: 'Русский',
    flag: '🇷🇺',
    voiceProfiles: ['ru-RU-SvetlanaNeural'],
  );

  static const italian = Language(
    code: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    flag: '🇮🇹',
    voiceProfiles: ['it-IT-ElsaNeural'],
  );

  static const hindi = Language(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    flag: '🇮🇳',
    voiceProfiles: ['hi-IN-SwaraNeural'],
  );

  static final List<Language> all = [
    english,
    spanish,
    french,
    german,
    chinese,
    japanese,
    korean,
    arabic,
    portuguese,
    russian,
    italian,
    hindi,
  ];

  static Language? fromCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
}
