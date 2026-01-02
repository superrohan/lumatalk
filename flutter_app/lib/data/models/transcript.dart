import 'package:freezed_annotation/freezed_annotation.dart';
import 'translation.dart';

part 'transcript.freezed.dart';
part 'transcript.g.dart';

@freezed
class Transcript with _$Transcript {
  const factory Transcript({
    required String id,
    required String sourceLang,
    required String targetLang,
    required DateTime startTime,
    DateTime? endTime,
    @Default([]) List<Translation> translations,
    @Default('') String title,
  }) = _Transcript;

  factory Transcript.fromJson(Map<String, dynamic> json) =>
      _$TranscriptFromJson(json);
}
