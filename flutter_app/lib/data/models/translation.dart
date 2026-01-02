import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation.freezed.dart';
part 'translation.g.dart';

@freezed
class Translation with _$Translation {
  const factory Translation({
    required String id,
    required String sourceText,
    required String targetText,
    required String sourceLang,
    required String targetLang,
    required DateTime timestamp,
    @Default(false) bool isFinal,
    @Default(1.0) double confidence,
    @Default(false) bool isSaved,
  }) = _Translation;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);
}

enum TranslationState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

@freezed
class TranslationSession with _$TranslationSession {
  const factory TranslationSession({
    required String id,
    required String sourceLang,
    required String targetLang,
    required DateTime startTime,
    DateTime? endTime,
    @Default([]) List<Translation> translations,
    @Default(TranslationState.idle) TranslationState state,
    String? errorMessage,
  }) = _TranslationSession;

  factory TranslationSession.fromJson(Map<String, dynamic> json) =>
      _$TranslationSessionFromJson(json);
}
