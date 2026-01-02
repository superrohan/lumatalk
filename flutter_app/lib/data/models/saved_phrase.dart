import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_phrase.freezed.dart';
part 'saved_phrase.g.dart';

@freezed
class SavedPhrase with _$SavedPhrase {
  const factory SavedPhrase({
    required String id,
    required String sourceText,
    required String targetText,
    required String sourceLang,
    required String targetLang,
    required DateTime createdAt,
    @Default([]) List<String> tags,
    @Default(0) int reviewCount,
    DateTime? lastReviewedAt,
  }) = _SavedPhrase;

  factory SavedPhrase.fromJson(Map<String, dynamic> json) =>
      _$SavedPhraseFromJson(json);
}
