import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/language.dart';
import '../../../data/models/translation.dart';
import '../../../services/webrtc/webrtc_service.dart';
import 'dart:async';

part 'live_translation_provider.freezed.dart';

@freezed
class LiveTranslationState with _$LiveTranslationState {
  const factory LiveTranslationState({
    @Default('en') String sourceLang,
    @Default('es') String targetLang,
    @Default('') String currentSourceText,
    @Default('') String currentTargetText,
    @Default(false) bool isSourceFinal,
    @Default(false) bool isTargetFinal,
    @Default(1.0) double sourceConfidence,
    @Default(1.0) double targetConfidence,
    @Default(false) bool isListening,
    @Default(false) bool isProcessing,
    @Default(false) bool isSpeaking,
    @Default(0.0) double audioLevel,
    @Default([]) List<Translation> sessionHistory,
    String? error,
  }) = _LiveTranslationState;
}

class LiveTranslationNotifier extends StateNotifier<LiveTranslationState> {
  LiveTranslationNotifier(this._webrtcService) : super(const LiveTranslationState()) {
    _initialize();
  }

  final WebRTCService _webrtcService;
  StreamSubscription? _asrPartialSub;
  StreamSubscription? _asrFinalSub;
  StreamSubscription? _mtResultSub;
  StreamSubscription? _ttsAudioSub;

  Future<void> _initialize() async {
    try {
      await _webrtcService.initialize();
      _setupListeners();
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize WebRTC: $e');
    }
  }

  void _setupListeners() {
    // Listen to ASR partial results
    _asrPartialSub = _webrtcService.onAsrPartial.listen((data) {
      state = state.copyWith(
        currentSourceText: data['text'] as String,
        isSourceFinal: false,
        sourceConfidence: (data['confidence'] as num?)?.toDouble() ?? 1.0,
      );
    });

    // Listen to ASR final results
    _asrFinalSub = _webrtcService.onAsrFinal.listen((data) {
      final text = data['text'] as String;
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 1.0;

      state = state.copyWith(
        currentSourceText: text,
        isSourceFinal: true,
        sourceConfidence: confidence,
        isProcessing: true,
      );

      // Request translation
      _requestTranslation(text);
    });

    // Listen to MT results
    _mtResultSub = _webrtcService.onMtResult.listen((data) {
      final translatedText = data['text'] as String;

      state = state.copyWith(
        currentTargetText: translatedText,
        isTargetFinal: true,
        targetConfidence: 1.0,
        isProcessing: false,
        isSpeaking: true,
      );

      // Request TTS
      _requestTTS(translatedText);

      // Add to session history
      final translation = Translation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: state.currentSourceText,
        targetText: translatedText,
        sourceLang: state.sourceLang,
        targetLang: state.targetLang,
        timestamp: DateTime.now(),
        isFinal: true,
        confidence: state.sourceConfidence,
      );

      state = state.copyWith(
        sessionHistory: [...state.sessionHistory, translation],
      );
    });

    // Listen to TTS audio chunks
    _ttsAudioSub = _webrtcService.onTtsAudio.listen((data) {
      final isFinal = data['isFinal'] as bool? ?? false;
      if (isFinal) {
        state = state.copyWith(isSpeaking: false);
      }
    });
  }

  void toggleListening() {
    if (state.isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    try {
      await _webrtcService.createOffer();
      state = state.copyWith(
        isListening: true,
        currentSourceText: '',
        currentTargetText: '',
        isSourceFinal: false,
        isTargetFinal: false,
        error: null,
      );

      // Send control message to start ASR
      _webrtcService.sendControlMessage({
        'type': 'start_asr',
        'sourceLang': state.sourceLang,
        'targetLang': state.targetLang,
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to start listening: $e');
    }
  }

  void _stopListening() {
    state = state.copyWith(isListening: false);

    // Send control message to stop ASR
    _webrtcService.sendControlMessage({
      'type': 'stop_asr',
    });
  }

  void _requestTranslation(String text) {
    _webrtcService.sendControlMessage({
      'type': 'translate',
      'text': text,
      'sourceLang': state.sourceLang,
      'targetLang': state.targetLang,
    });
  }

  void _requestTTS(String text) {
    _webrtcService.sendControlMessage({
      'type': 'synthesize',
      'text': text,
      'lang': state.targetLang,
      'voice': _getVoiceForLanguage(state.targetLang),
    });
  }

  String _getVoiceForLanguage(String langCode) {
    final language = Languages.fromCode(langCode);
    return language?.voiceProfiles.isNotEmpty == true
        ? language!.voiceProfiles.first
        : 'en-US-JennyNeural';
  }

  void replayTranslation() {
    if (state.currentTargetText.isEmpty) return;

    state = state.copyWith(isSpeaking: true);
    _requestTTS(state.currentTargetText);
  }

  void clearCurrent() {
    state = state.copyWith(
      currentSourceText: '',
      currentTargetText: '',
      isSourceFinal: false,
      isTargetFinal: false,
      sourceConfidence: 1.0,
      targetConfidence: 1.0,
    );
  }

  Future<void> saveCurrentPhrase() async {
    if (state.currentSourceText.isEmpty || state.currentTargetText.isEmpty) {
      return;
    }

    // TODO: Save to database via repository
    // final savedPhrase = SavedPhrase(
    //   id: uuid.v4(),
    //   sourceText: state.currentSourceText,
    //   targetText: state.currentTargetText,
    //   sourceLang: state.sourceLang,
    //   targetLang: state.targetLang,
    //   createdAt: DateTime.now(),
    // );
    // await ref.read(savedRepositoryProvider).savePhrase(savedPhrase);
  }

  Future<void> saveSession() async {
    if (state.sessionHistory.isEmpty) return;

    // TODO: Save entire session as transcript
    // final transcript = Transcript(
    //   id: uuid.v4(),
    //   sourceLang: state.sourceLang,
    //   targetLang: state.targetLang,
    //   startTime: state.sessionHistory.first.timestamp,
    //   endTime: DateTime.now(),
    //   translations: state.sessionHistory,
    //   title: 'Session ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    // );
    // await ref.read(savedRepositoryProvider).saveTranscript(transcript);

    // Clear session after saving
    state = state.copyWith(sessionHistory: []);
  }

  void setSourceLanguage(Language language) {
    state = state.copyWith(sourceLang: language.code);
  }

  void setTargetLanguage(Language language) {
    state = state.copyWith(targetLang: language.code);
  }

  void swapLanguages() {
    state = state.copyWith(
      sourceLang: state.targetLang,
      targetLang: state.sourceLang,
      currentSourceText: state.currentTargetText,
      currentTargetText: state.currentSourceText,
    );
  }

  @override
  void dispose() {
    _asrPartialSub?.cancel();
    _asrFinalSub?.cancel();
    _mtResultSub?.cancel();
    _ttsAudioSub?.cancel();
    _webrtcService.dispose();
    super.dispose();
  }
}

final liveTranslationProvider =
    StateNotifierProvider<LiveTranslationNotifier, LiveTranslationState>((ref) {
  return LiveTranslationNotifier(WebRTCService());
});
