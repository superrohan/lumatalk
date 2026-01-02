# LumaTalk - Complete Setup Guide

## 🚀 Quick Start (5 Minutes)

This guide will get you running the complete LumaTalk stack locally.

---

## Step 1: Generate Remaining Files

Run the Python generator to create all boilerplate files:

```bash
cd lumatalk
python generate_project.py
```

**Output**: 30+ files created including models, DAOs, services, and Dockerfiles.

---

## Step 2: Flutter Setup

### Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` files for immutable models
- `*.g.dart` files for JSON serialization
- Riverpod provider code

**Expected output**: ~20-30 generated files

### Configure Backend URL

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String backendUrl = 'http://localhost:8080';  // For Android emulator use 10.0.2.2:8080
static const String wsUrl = 'ws://localhost:8080/ws';
```

---

## Step 3: Backend Setup

### Option A: Docker (Recommended)

From project root:

```bash
docker-compose up -d
```

This starts:
- ✅ PostgreSQL (port 5432)
- ✅ Spring Boot backend (port 8080)
- ✅ ASR worker (port 8001)
- ✅ MT worker (port 8002)
- ✅ TTS worker (port 8003)
- ✅ TURN server (port 3478)

Check status:
```bash
docker-compose ps
```

View logs:
```bash
docker-compose logs -f backend
docker-compose logs -f asr_worker
```

### Option B: Manual Setup

#### PostgreSQL

```bash
# Install PostgreSQL 15+
createdb lumatalk
createuser lumatalk -P  # Enter password: changeme
```

#### Spring Boot Backend

```bash
cd backend

# Set environment variables
export DB_USERNAME=lumatalk
export DB_PASSWORD=changeme
export JWT_SECRET=your_256_bit_secret_key_here

# Build and run
./mvnw clean install
./mvnw spring-boot:run
```

Backend runs on `http://localhost:8080`

#### Python Workers

**ASR Worker**:
```bash
cd inference/asr_worker
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

**MT Worker**:
```bash
cd inference/mt_worker
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set API keys
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcp-credentials.json
# OR
export AZURE_TRANSLATOR_KEY=your_key
export AZURE_TRANSLATOR_REGION=eastus

python main.py
```

**TTS Worker**:
```bash
cd inference/tts_worker
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set API keys
export AZURE_SPEECH_KEY=your_key
export AZURE_SPEECH_REGION=eastus
# OR
export ELEVENLABS_API_KEY=your_key

python main.py
```

---

## Step 4: API Keys Configuration

### Required API Keys

You'll need keys for translation and TTS services.

### Google Cloud Translation

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project
3. Enable Cloud Translation API
4. Create a service account
5. Download JSON credentials
6. Set path: `GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json`

### Azure Translator (Alternative)

1. Go to [Azure Portal](https://portal.azure.com/)
2. Create "Translator" resource
3. Copy API key and region
4. Set: `AZURE_TRANSLATOR_KEY` and `AZURE_TRANSLATOR_REGION`

### Azure Speech (TTS)

1. Go to [Azure Portal](https://portal.azure.com/)
2. Create "Speech Services" resource
3. Copy API key and region
4. Set: `AZURE_SPEECH_KEY` and `AZURE_SPEECH_REGION`

### ElevenLabs (Alternative TTS)

1. Sign up at [ElevenLabs](https://elevenlabs.io/)
2. Get API key from settings
3. Set: `ELEVENLABS_API_KEY`

### Environment File Template

Create `.env` in project root:

```bash
# Database
DB_USERNAME=lumatalk
DB_PASSWORD=changeme

# JWT
JWT_SECRET=your_256_bit_secret_key_here_minimum_32_chars

# Google Cloud (option 1)
GOOGLE_APPLICATION_CREDENTIALS=/path/to/gcp-credentials.json

# Azure Translator (option 2)
AZURE_TRANSLATOR_KEY=your_key_here
AZURE_TRANSLATOR_REGION=eastus

# Azure Speech
AZURE_SPEECH_KEY=your_speech_key_here
AZURE_SPEECH_REGION=eastus

# ElevenLabs (alternative)
ELEVENLABS_API_KEY=your_elevenlabs_key

# TURN Server
TURN_USERNAME=turnuser
TURN_PASSWORD=turnpass

# AWS S3 (optional)
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
```

---

## Step 5: Run the Flutter App

### Android

```bash
cd flutter_app

# Start emulator or connect device
flutter devices

# Run
flutter run

# Or build APK
flutter build apk --release
```

### iOS (macOS only)

```bash
cd flutter_app

# Install pods
cd ios
pod install
cd ..

# Run
flutter run -d ios

# Or build IPA
flutter build ios --release
```

---

## 🧪 Testing the Setup

### 1. Test Backend Health

```bash
curl http://localhost:8080/actuator/health
```

Expected: `{"status":"UP"}`

### 2. Test ASR Worker

```bash
curl http://localhost:8001/health
```

Expected: `{"status":"healthy","service":"asr_worker"}`

### 3. Test MT Worker

```bash
curl -X POST http://localhost:8002/translate \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello","source_lang":"en","target_lang":"es"}'
```

Expected: `{"translated_text":"Hola","source_lang":"en","target_lang":"es","confidence":1.0}`

### 4. Test TTS Worker

```bash
curl http://localhost:8003/health
```

Expected: `{"status":"healthy","service":"tts_worker"}`

### 5. Test Flutter App

1. Open app
2. See Live Translation screen
3. Select source language (English)
4. Select target language (Spanish)
5. Tap microphone button
6. Speak: "Hello, how are you?"
7. See transcription appear
8. See translation appear: "Hola, ¿cómo estás?"
9. Hear audio playback

---

## 🐛 Troubleshooting

### Flutter Issues

**Build fails**:
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Android emulator audio**:
- Use physical device for audio testing
- Emulator audio is limited

**iOS build fails**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

### Backend Issues

**Database connection fails**:
```bash
# Check PostgreSQL is running
pg_isready

# Check credentials in application.yml
cat backend/src/main/resources/application.yml
```

**Port already in use**:
```bash
# Find process on port 8080
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill it
kill -9 <PID>
```

### Inference Worker Issues

**faster-whisper fails to download**:
```bash
# Pre-download model
python -c "from faster_whisper import WhisperModel; WhisperModel('base', device='cpu')"
```

**GPU not detected**:
```bash
# Check CUDA
nvidia-smi

# Install CUDA-enabled PyTorch
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

**API key invalid**:
- Double-check key has no extra spaces
- Verify resource is in correct region
- Check API quota not exceeded

### Docker Issues

**Container fails to start**:
```bash
# Check logs
docker-compose logs <service_name>

# Restart specific service
docker-compose restart <service_name>

# Full reset
docker-compose down -v
docker-compose up -d
```

**Out of memory**:
```bash
# Increase Docker memory limit
# Docker Desktop → Settings → Resources → Memory (8GB recommended)
```

---

## 📱 Mobile App Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

Add:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)

Add:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>LumaTalk needs microphone access for voice translation</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>LumaTalk needs speech recognition for translation</string>
```

---

## 🔧 Development Workflow

### Hot Reload (Flutter)

```bash
flutter run
# Press 'r' to hot reload
# Press 'R' to hot restart
```

### Backend Auto-Reload (Spring Boot DevTools)

Add to `pom.xml`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
</dependency>
```

### Inference Worker Auto-Reload

```bash
# Install uvicorn with reload
uvicorn main:app --reload --port 8001
```

---

## 📊 Monitoring

### Health Checks

```bash
# All services
curl http://localhost:8080/actuator/health
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
```

### Database

```bash
# Connect to PostgreSQL
psql -U lumatalk -d lumatalk

# Check tables
\dt

# Query sessions
SELECT * FROM sessions ORDER BY start_time DESC LIMIT 10;
```

### Logs

```bash
# Docker logs
docker-compose logs -f --tail=100

# Specific service
docker-compose logs -f backend

# Flutter logs
flutter logs
```

---

## 🚢 Production Deployment

See [DEPLOYMENT.md](./docs/DEPLOYMENT.md) for:
- Kubernetes manifests
- CI/CD pipelines
- Monitoring setup
- Scaling strategies
- Security hardening

---

## 💡 Tips

1. **Use Docker Compose** for easiest setup
2. **Start with Azure** - simpler than Google Cloud
3. **Test on physical device** - emulator audio is limited
4. **Monitor latency** - aim for <1.5s end-to-end
5. **Cache common phrases** - reduces API costs
6. **Use TURN server** - essential for production

---

## 📞 Support

- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: [README.md](./README.md), [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)
- **Architecture**: See architecture diagram in README

---

**Setup time**: 15-20 minutes (with Docker)
**First translation**: <5 minutes after setup

Happy translating! 🌍
