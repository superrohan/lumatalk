# LumaTalk - Live Speech Translation Platform

A production-grade cross-platform mobile application for real-time speech translation with live audio I/O, text translation, and phrase management.

## 🎯 Features

### 1️⃣ Live Translation Mode
- **Real-time speech translation** with <1.5s latency
- **Voice Activity Detection (VAD)** using Silero VAD
- **Streaming ASR** with partial and final transcriptions
- **Neural TTS** with custom voice cloning support
- **Waveform visualization** showing active listening state
- **Barge-in control** - interrupt TTS playback when speaking
- **Language swapping** - instant source/target toggle
- **Session transcripts** - save entire conversations

### 2️⃣ Text Translation Mode
- Type or dictate text input
- Sentence vs phrase segmentation
- Translation history with search
- Save favorite translations
- Batch translation support

### 3️⃣ Saved Library
- Local-first SQLite database
- Full-text search across saved phrases
- Filter by language pairs
- Export to PDF/TXT
- **Flashcard mode** with spaced repetition
- Offline access to saved content

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Live Screen  │  │ Text Screen  │  │ Saved Screen │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                    ┌───────┴────────┐                        │
│                    │ Riverpod State │                        │
│                    └───────┬────────┘                        │
│                            │                                 │
│         ┌──────────────────┼──────────────────┐             │
│         │                  │                  │             │
│   ┌─────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐      │
│   │  WebRTC    │   │   Local DB  │   │   Audio     │      │
│   │  Service   │   │  (SQLite)   │   │   System    │      │
│   └─────┬──────┘   └─────────────┘   └──────┬──────┘      │
└─────────┼──────────────────────────────────────┼───────────┘
          │                                      │
          │ WebRTC (Audio + DataChannel)        │ Local Audio I/O
          │                                      │
┌─────────▼──────────────────────────────────────▼───────────┐
│                    Spring Boot Backend                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   WebRTC     │  │     REST     │  │  WebSocket   │     │
│  │   Gateway    │  │     API      │  │  Signaling   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                            │                                │
│                    ┌───────┴────────┐                       │
│                    │   PostgreSQL   │                       │
│                    └────────────────┘                       │
└──────┬─────────────────────────────────────────┬───────────┘
       │                                          │
       │ gRPC/HTTP                                │ gRPC/HTTP
       │                                          │
┌──────▼──────────┐  ┌──────────────┐  ┌────────▼──────────┐
│  ASR Worker     │  │  MT Worker   │  │   TTS Worker      │
│                 │  │              │  │                   │
│ faster-whisper  │  │ Cloud Trans. │  │ Azure/ElevenLabs  │
│ + Silero VAD    │  │ or NLLB      │  │ Streaming TTS     │
└─────────────────┘  └──────────────┘  └───────────────────┘
```

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.16+
- **State Management**: flutter_riverpod
- **Routing**: go_router
- **WebRTC**: flutter_webrtc
- **Audio**: just_audio, record
- **Database**: sqflite + path_provider
- **UI**: Material 3 with custom theme

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.2+
- **Language**: Java 17
- **Database**: PostgreSQL 15
- **ORM**: Spring Data JPA / Hibernate
- **WebSocket**: Spring WebSocket + STOMP
- **Security**: Spring Security + JWT
- **Storage**: S3-compatible (MinIO/AWS S3)

### Inference Workers (Python)
- **Framework**: FastAPI 0.104+
- **ASR**: faster-whisper (CTranslate2)
- **VAD**: Silero VAD
- **MT**: Google Cloud Translation / Azure Translator / NLLB
- **TTS**: Azure Neural TTS / ElevenLabs
- **Audio Processing**: RNNoise for noise suppression

### DevOps
- **Containerization**: Docker + Docker Compose
- **Orchestration**: Kubernetes (optional)
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana

## 📋 Prerequisites

- **Flutter SDK**: 3.16.0 or higher
- **Dart**: 3.2.0 or higher
- **Java**: JDK 17
- **Python**: 3.10+
- **Node.js**: 18+ (for development tools)
- **Docker**: 24.0+ and Docker Compose
- **PostgreSQL**: 15+ (or use Docker)
- **Android Studio** / **Xcode** for mobile builds

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/lumatalk.git
cd lumatalk
```

### 2. Backend Setup

```bash
cd backend

# Set environment variables
cp .env.example .env
# Edit .env with your database credentials and API keys

# Build with Maven
./mvnw clean install

# Run Spring Boot
./mvnw spring-boot:run
```

The backend will start on `http://localhost:8080`

### 3. Inference Workers Setup

#### ASR Worker

```bash
cd inference/asr_worker

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Download Silero VAD model (automatic on first run)

# Run ASR worker
python main.py
```

ASR worker runs on `http://localhost:8001`

#### MT Worker

```bash
cd inference/mt_worker

python -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# Set API keys in .env
# GOOGLE_CLOUD_PROJECT_ID=your-project
# GOOGLE_APPLICATION_CREDENTIALS=path/to/credentials.json
# OR
# AZURE_TRANSLATOR_KEY=your-key
# AZURE_TRANSLATOR_REGION=your-region

python main.py
```

MT worker runs on `http://localhost:8002`

#### TTS Worker

```bash
cd inference/tts_worker

python -m venv venv
source venv/bin/activate

pip install -r requirements.txt

# Set TTS API keys in .env
# AZURE_SPEECH_KEY=your-key
# AZURE_SPEECH_REGION=your-region
# OR
# ELEVENLABS_API_KEY=your-key

python main.py
```

TTS worker runs on `http://localhost:8003`

### 4. Flutter App Setup

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Generate code (for freezed, riverpod, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Update backend URL in lib/core/constants/app_constants.dart
# Change backendUrl and wsUrl to your backend address

# Run on Android
flutter run

# Or run on iOS (macOS only)
flutter run -d ios
```

### 5. Docker Compose (Recommended for Production)

```bash
# From project root
docker-compose up -d

# This starts:
# - PostgreSQL
# - Spring Boot backend
# - ASR worker
# - MT worker
# - TTS worker
# - TURN server
```

## 🔐 Configuration

### Backend Configuration (`backend/src/main/resources/application.yml`)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/lumatalk
    username: ${DB_USERNAME:lumatalk}
    password: ${DB_PASSWORD:changeme}

  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

server:
  port: 8080

lumatalk:
  inference:
    asr-url: http://localhost:8001
    mt-url: http://localhost:8002
    tts-url: http://localhost:8003

  webrtc:
    stun-servers:
      - stun:stun.l.google.com:19302
    turn-servers:
      - url: turn:your-turn-server.com:3478
        username: ${TURN_USERNAME}
        credential: ${TURN_CREDENTIAL}

  storage:
    type: s3  # or 'local'
    s3:
      bucket: lumatalk-audio
      region: us-east-1
      access-key: ${AWS_ACCESS_KEY_ID}
      secret-key: ${AWS_SECRET_ACCESS_KEY}
```

### Flutter Configuration (`flutter_app/lib/core/constants/app_constants.dart`)

```dart
class AppConstants {
  // TODO: Replace with your actual backend URL
  static const String backendUrl = 'https://api.lumatalk.example.com';
  static const String wsUrl = 'wss://api.lumatalk.example.com/ws';

  // ... rest of config
}
```

### API Keys Required

Create `.env` files in appropriate directories:

**Backend** (`.env`):
```bash
DB_USERNAME=lumatalk
DB_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_key_min_256_bits
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
TURN_USERNAME=turnuser
TURN_CREDENTIAL=turnpass
```

**Inference Workers** (`.env` in each worker directory):
```bash
# MT Worker
GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcp-credentials.json
# OR
AZURE_TRANSLATOR_KEY=your_azure_key
AZURE_TRANSLATOR_REGION=eastus

# TTS Worker
AZURE_SPEECH_KEY=your_speech_key
AZURE_SPEECH_REGION=eastus
# OR
ELEVENLABS_API_KEY=your_elevenlabs_key
```

## 📱 Building for Production

### Android

```bash
cd flutter_app

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Outputs:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
cd flutter_app

# Build for iOS (macOS only)
flutter build ios --release

# Or build IPA
flutter build ipa --release

# Output: build/ios/ipa/lumatalk.ipa
```

## 🧪 Testing

### Flutter Tests

```bash
cd flutter_app
flutter test
flutter test --coverage
```

### Backend Tests

```bash
cd backend
./mvnw test
```

### Integration Tests

```bash
cd flutter_app
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subscription_tier VARCHAR(50) DEFAULT 'free'
);
```

### Sessions Table
```sql
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    source_lang VARCHAR(10),
    target_lang VARCHAR(10),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    total_utterances INT DEFAULT 0
);
```

### Utterances Table
```sql
CREATE TABLE utterances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id),
    source_text TEXT,
    translated_text TEXT,
    confidence FLOAT,
    timestamp TIMESTAMP,
    audio_url VARCHAR(500)
);
```

### Saved Phrases Table
```sql
CREATE TABLE saved_phrases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    source_text TEXT,
    translated_text TEXT,
    source_lang VARCHAR(10),
    target_lang VARCHAR(10),
    created_at TIMESTAMP,
    tags TEXT[]
);
```

Full schema: `backend/src/main/resources/db/migration/V1__initial_schema.sql`

## 🌐 API Documentation

### REST Endpoints

#### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login and get JWT
- `POST /api/auth/refresh` - Refresh JWT token

#### Sessions
- `POST /api/sessions` - Create new translation session
- `GET /api/sessions/{id}` - Get session details
- `GET /api/sessions` - List user sessions
- `DELETE /api/sessions/{id}` - Delete session

#### Translation
- `POST /api/translate/text` - Translate text (sync)
- `POST /api/translate/stream` - Start streaming translation

#### Saved Phrases
- `GET /api/saved` - List saved phrases
- `POST /api/saved` - Save new phrase
- `DELETE /api/saved/{id}` - Delete phrase
- `GET /api/saved/export` - Export phrases (PDF/TXT)

### WebSocket Signaling

Connect to `ws://backend-url/ws/signaling`

**Message Types:**

```json
// Offer
{
  "type": "offer",
  "sdp": "...",
  "sessionId": "uuid"
}

// Answer
{
  "type": "answer",
  "sdp": "...",
  "sessionId": "uuid"
}

// ICE Candidate
{
  "type": "ice-candidate",
  "candidate": {...},
  "sessionId": "uuid"
}
```

### DataChannel Messages

**ASR Partial Result:**
```json
{
  "type": "asr_partial",
  "text": "Hello, how are",
  "confidence": 0.92
}
```

**ASR Final Result:**
```json
{
  "type": "asr_final",
  "text": "Hello, how are you?",
  "confidence": 0.95
}
```

**MT Result:**
```json
{
  "type": "mt_final",
  "text": "Hola, ¿cómo estás?",
  "sourceLang": "en",
  "targetLang": "es"
}
```

**TTS Stream:**
```json
{
  "type": "tts_audio",
  "audio": "base64-encoded-opus",
  "isFinal": false
}
```

## 🎨 UI Components

### Live Translation Screen
- Language selector dropdowns (source/target)
- Swap languages button
- Large bilingual caption cards
- Waveform visualizer
- Mic button (push-to-talk or continuous)
- Replay button
- Save transcript button

### Text Translation Screen
- Text input area with dictation
- Segmentation toggle (sentence/phrase)
- Real-time translation display
- History list
- Save button for each translation

### Saved Library Screen
- Search bar with filters
- List/grid view toggle
- Category tabs (Phrases/Transcripts)
- Export button
- Flashcard mode button

### Flashcard Screen
- Card flip animation
- Progress indicator
- Swipe gestures (know/don't know)
- Spaced repetition algorithm

## 🔒 Security

- **Authentication**: JWT-based with refresh tokens
- **HTTPS**: All production traffic over TLS 1.3
- **TURN server**: Credentials rotated every 24h
- **Rate limiting**: Per-user API limits
- **Data encryption**: At-rest encryption for S3 storage
- **PII handling**: GDPR-compliant data retention

## 📈 Performance Optimization

### Latency Targets
- **ASR partial result**: <300ms
- **ASR final result**: <800ms
- **MT translation**: <400ms
- **TTS first audio**: <500ms
- **End-to-end**: <1.5s

### Optimization Strategies
1. **WebRTC direct peer connection** for minimal latency
2. **Streaming ASR** with partial results
3. **Cached TTS** for common phrases
4. **Edge deployment** of inference workers
5. **GPU acceleration** for ASR/TTS
6. **Connection pooling** to cloud MT APIs
7. **Local VAD** to reduce unnecessary ASR calls

## 🌍 Localization

Currently supported languages:
- English, Spanish, French, German
- Chinese (Mandarin), Japanese, Korean
- Arabic, Hindi, Portuguese, Russian, Italian

**Adding a new language:**

1. Add to `Languages` class in `lib/data/models/language.dart`
2. Add voice profiles in `app_constants.dart`
3. Update backend `SupportedLanguages` enum
4. Ensure MT and TTS workers support the language

## 🐛 Troubleshooting

### Common Issues

**WebRTC connection fails:**
- Check firewall allows UDP traffic
- Verify STUN/TURN server configuration
- Enable verbose WebRTC logging

**Audio not playing:**
- Check device permissions (microphone/speakers)
- Verify audio session configuration (iOS)
- Check TTS worker is running

**Database migration fails:**
- Ensure PostgreSQL version ≥15
- Check database user has CREATE permissions
- Run migrations manually: `./mvnw flyway:migrate`

**Flutter build fails:**
- Run `flutter clean && flutter pub get`
- Regenerate code: `flutter pub run build_runner build --delete-conflicting-outputs`
- Check Flutter version: `flutter --version`

## 📚 Additional Documentation

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Detailed system architecture
- [API.md](./docs/API.md) - Complete API reference
- [DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Production deployment guide

## 🤝 Contributing

We welcome contributions!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

## 🙏 Acknowledgments

- **faster-whisper** - Fast ASR inference
- **Silero VAD** - Voice activity detection
- **Azure Neural TTS** - High-quality speech synthesis
- **Flutter team** - Amazing cross-platform framework
- **Spring Boot** - Robust backend framework

## 📞 Support

- **Documentation**: https://docs.lumatalk.example.com
- **Issues**: https://github.com/yourusername/lumatalk/issues
- **Email**: support@lumatalk.example.com

---

**Built with ❤️ by the LumaTalk Team**