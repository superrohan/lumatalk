class AppConstants {
  // API Configuration
  // TODO: Replace with your actual backend URL
  static const String backendUrl = 'https://api.lumatalk.example.com';
  static const String wsUrl = 'wss://api.lumatalk.example.com/ws';

  // WebRTC Configuration
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {
        'urls': 'turn:turn.lumatalk.example.com:3478',
        // TODO: Add TURN credentials
        'username': 'turnuser',
        'credential': 'turnpassword',
      }
    ]
  };

  // Audio Configuration
  static const int sampleRate = 16000;
  static const int channels = 1;
  static const int bitDepth = 16;
  static const Duration vadSilenceThreshold = Duration(milliseconds: 800);
  static const double vadEnergyThreshold = 0.02;

  // Translation Configuration
  static const Duration translationTimeout = Duration(seconds: 10);
  static const int maxTranslationLength = 5000;
  static const Duration partialUpdateInterval = Duration(milliseconds: 300);

  // Audio Playback
  static const Duration audioBufferSize = Duration(milliseconds: 100);
  static const bool enableBargeIn = true;
  static const double duckingVolume = 0.2;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int waveformBars = 40;
  static const double waveformHeight = 80;

  // Database
  static const String databaseName = 'lumatalk.db';
  static const int databaseVersion = 1;

  // Export
  static const String exportDateFormat = 'yyyy-MM-dd_HH-mm-ss';
  static const int maxExportItems = 1000;

  // Flashcards
  static const Duration flashcardFlipDuration = Duration(milliseconds: 600);
  static const int dailyFlashcardGoal = 20;

  // Limits
  static const int maxSavedPhrases = 10000;
  static const int maxTranscriptLength = 50000;
  static const int searchResultsLimit = 100;

  // Language Codes (ISO 639-1)
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'tr': 'Turkish',
    'pl': 'Polish',
    'nl': 'Dutch',
    'sv': 'Swedish',
    'da': 'Danish',
    'fi': 'Finnish',
    'no': 'Norwegian',
    'cs': 'Czech',
    'el': 'Greek',
    'he': 'Hebrew',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'id': 'Indonesian',
  };

  // Voice Profiles
  static const Map<String, List<String>> languageVoices = {
    'en': ['en-US-JennyNeural', 'en-US-GuyNeural', 'en-GB-SoniaNeural'],
    'es': ['es-ES-ElviraNeural', 'es-MX-DaliaNeural'],
    'fr': ['fr-FR-DeniseNeural', 'fr-CA-SylvieNeural'],
    'de': ['de-DE-KatjaNeural', 'de-AT-IngridNeural'],
    'zh': ['zh-CN-XiaoxiaoNeural', 'zh-TW-HsiaoChenNeural'],
    'ja': ['ja-JP-NanamiNeural', 'ja-JP-KeitaNeural'],
    'ko': ['ko-KR-SunHiNeural', 'ko-KR-InJoonNeural'],
  };

  // Error Messages
  static const String errorMicPermission = 'Microphone permission is required';
  static const String errorNoInternet = 'No internet connection';
  static const String errorTranslationFailed = 'Translation failed';
  static const String errorAudioPlayback = 'Audio playback failed';
  static const String errorDatabaseAccess = 'Database access failed';

  // Success Messages
  static const String successPhraseSaved = 'Phrase saved successfully';
  static const String successTranscriptSaved = 'Transcript saved successfully';
  static const String successExported = 'Exported successfully';
}
