import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../widgets/language_selector.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/translation_card.dart';
import '../widgets/control_panel.dart';
import '../providers/live_translation_provider.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveTranslationProvider);
    final notifier = ref.read(liveTranslationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Translation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Language Selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LanguageSelector(
                sourceLang: state.sourceLang,
                targetLang: state.targetLang,
                onSourceChanged: notifier.setSourceLanguage,
                onTargetChanged: notifier.setTargetLanguage,
                onSwap: notifier.swapLanguages,
              ),
            ),

            // Translation Display
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Source Text Card
                    TranslationCard(
                      lang: state.sourceLang,
                      text: state.currentSourceText,
                      isPartial: !state.isSourceFinal,
                      confidence: state.sourceConfidence,
                      backgroundColor: AppColors.sourceLanguage.withOpacity(0.1),
                      borderColor: AppColors.sourceLanguage,
                    ),

                    const SizedBox(height: 16),

                    // Arrow indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Target Text Card
                    TranslationCard(
                      lang: state.targetLang,
                      text: state.currentTargetText,
                      isPartial: !state.isTargetFinal,
                      confidence: state.targetConfidence,
                      backgroundColor: AppColors.targetLanguage.withOpacity(0.1),
                      borderColor: AppColors.targetLanguage,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Waveform Visualizer
            WaveformVisualizer(
              isActive: state.isListening,
              audioLevel: state.audioLevel,
            ),

            // Control Panel
            ControlPanel(
              isListening: state.isListening,
              isProcessing: state.isProcessing,
              isSpeaking: state.isSpeaking,
              onMicPressed: notifier.toggleListening,
              onReplayPressed: state.currentTargetText.isNotEmpty
                  ? notifier.replayTranslation
                  : null,
              onSavePressed: state.currentTargetText.isNotEmpty
                  ? () => notifier.saveCurrentPhrase()
                  : null,
              onClearPressed: state.currentSourceText.isNotEmpty
                  ? notifier.clearCurrent
                  : null,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
