import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard.freezed.dart';
part 'flashcard.g.dart';

@freezed
class Flashcard with _$Flashcard {
  const factory Flashcard({
    required String id,
    required String front,
    required String back,
    required String sourceLang,
    required String targetLang,
    @Default(0) int easeFactor,
    @Default(0) int repetitions,
    @Default(0) int interval,
    DateTime? nextReview,
    DateTime? createdAt,
  }) = _Flashcard;

  factory Flashcard.fromJson(Map<String, dynamic> json) =>
      _$FlashcardFromJson(json);
}
