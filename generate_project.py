#!/usr/bin/env python3
"""
LumaTalk Project Generator
Generates all remaining boilerplate files for the Flutter app, backend, and inference workers.
Run this script from the project root: python generate_project.py
"""

import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent

def create_file(path: str, content: str):
    """Create a file with the given content, creating directories as needed."""
    file_path = PROJECT_ROOT / path
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Created {path}")

def generate_flutter_models():
    """Generate Flutter data models."""

    # saved_phrase.dart
    create_file('flutter_app/lib/data/models/saved_phrase.dart', '''import 'package:freezed_annotation/freezed_annotation.dart';

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
''')

    # transcript.dart
    create_file('flutter_app/lib/data/models/transcript.dart', '''import 'package:freezed_annotation/freezed_annotation.dart';
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
''')

    # flashcard.dart
    create_file('flutter_app/lib/data/models/flashcard.dart', '''import 'package:freezed_annotation/freezed_annotation.dart';

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
''')

def generate_flutter_database():
    """Generate Flutter database layer."""

    # database.dart
    create_file('flutter_app/lib/data/database/database.dart', '''import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE saved_phrases (
        id TEXT PRIMARY KEY,
        source_text TEXT NOT NULL,
        target_text TEXT NOT NULL,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        tags TEXT,
        review_count INTEGER DEFAULT 0,
        last_reviewed_at INTEGER
      )
    """);

    await db.execute("""
      CREATE TABLE transcripts (
        id TEXT PRIMARY KEY,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        title TEXT,
        translations TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        source_lang TEXT NOT NULL,
        target_lang TEXT NOT NULL,
        ease_factor INTEGER DEFAULT 250,
        repetitions INTEGER DEFAULT 0,
        interval INTEGER DEFAULT 0,
        next_review INTEGER,
        created_at INTEGER
      )
    """);

    // Indices for faster queries
    await db.execute("CREATE INDEX idx_phrases_langs ON saved_phrases(source_lang, target_lang)");
    await db.execute("CREATE INDEX idx_phrases_created ON saved_phrases(created_at DESC)");
    await db.execute("CREATE INDEX idx_flashcards_review ON flashcards(next_review)");
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
''')

    # phrase_dao.dart
    create_file('flutter_app/lib/data/database/daos/phrase_dao.dart', '''import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../../models/saved_phrase.dart';
import '../database.dart';

class PhraseDao {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<SavedPhrase>> getAllPhrases() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<SavedPhrase?> getPhraseById(String id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<SavedPhrase>> searchPhrases(String query) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'source_text LIKE ? OR target_text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<List<SavedPhrase>> getPhrasesByLanguagePair(
    String sourceLang,
    String targetLang,
  ) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_phrases',
      where: 'source_lang = ? AND target_lang = ?',
      whereArgs: [sourceLang, targetLang],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => _fromMap(maps[i]));
  }

  Future<void> insertPhrase(SavedPhrase phrase) async {
    final db = await _db.database;
    await db.insert(
      'saved_phrases',
      _toMap(phrase),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePhrase(SavedPhrase phrase) async {
    final db = await _db.database;
    await db.update(
      'saved_phrases',
      _toMap(phrase),
      where: 'id = ?',
      whereArgs: [phrase.id],
    );
  }

  Future<void> deletePhrase(String id) async {
    final db = await _db.database;
    await db.delete(
      'saved_phrases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(SavedPhrase phrase) {
    return {
      'id': phrase.id,
      'source_text': phrase.sourceText,
      'target_text': phrase.targetText,
      'source_lang': phrase.sourceLang,
      'target_lang': phrase.targetLang,
      'created_at': phrase.createdAt.millisecondsSinceEpoch,
      'tags': jsonEncode(phrase.tags),
      'review_count': phrase.reviewCount,
      'last_reviewed_at': phrase.lastReviewedAt?.millisecondsSinceEpoch,
    };
  }

  SavedPhrase _fromMap(Map<String, dynamic> map) {
    return SavedPhrase(
      id: map['id'],
      sourceText: map['source_text'],
      targetText: map['target_text'],
      sourceLang: map['source_lang'],
      targetLang: map['target_lang'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      tags: List<String>.from(jsonDecode(map['tags'] ?? '[]')),
      reviewCount: map['review_count'] ?? 0,
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed_at'])
          : null,
    );
  }
}
''')

def generate_flutter_services():
    """Generate Flutter services."""

    # webrtc_service.dart
    create_file('flutter_app/lib/services/webrtc/webrtc_service.dart', '''import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import 'signaling_client.dart';
import 'data_channel_handler.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;

  final SignalingClient _signalingClient = SignalingClient();
  final DataChannelHandler _dataChannelHandler = DataChannelHandler();

  final _onAsrPartialController = StreamController<Map<String, dynamic>>.broadcast();
  final _onAsrFinalController = StreamController<Map<String, dynamic>>.broadcast();
  final _onMtResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _onTtsAudioController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onAsrPartial => _onAsrPartialController.stream;
  Stream<Map<String, dynamic>> get onAsrFinal => _onAsrFinalController.stream;
  Stream<Map<String, dynamic>> get onMtResult => _onMtResultController.stream;
  Stream<Map<String, dynamic>> get onTtsAudio => _onTtsAudioController.stream;

  Future<void> initialize() async {
    await _signalingClient.connect();
    await _createPeerConnection();
    await _setupLocalStream();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(AppConstants.iceServers);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _signalingClient.sendIceCandidate(candidate);
    };

    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      _setupDataChannel(channel);
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
    };
  }

  Future<void> _setupLocalStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': {
        'sampleRate': AppConstants.sampleRate,
        'channelCount': AppConstants.channels,
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localStream!.getAudioTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<void> _setupDataChannel(RTCDataChannel channel) async {
    _dataChannel = channel;

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      _dataChannelHandler.handleMessage(
        message,
        onAsrPartial: _onAsrPartialController.add,
        onAsrFinal: _onAsrFinalController.add,
        onMtResult: _onMtResultController.add,
        onTtsAudio: _onTtsAudioController.add,
      );
    };
  }

  Future<void> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await _signalingClient.sendOffer(offer);
  }

  Future<void> handleAnswer(RTCSessionDescription answer) async {
    await _peerConnection!.setRemoteDescription(answer);
  }

  Future<void> handleIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  void sendControlMessage(Map<String, dynamic> message) {
    _dataChannelHandler.sendMessage(_dataChannel!, message);
  }

  Future<void> dispose() async {
    await _localStream?.dispose();
    await _dataChannel?.close();
    await _peerConnection?.close();
    await _signalingClient.disconnect();

    await _onAsrPartialController.close();
    await _onAsrFinalController.close();
    await _onMtResultController.close();
    await _onTtsAudioController.close();
  }
}
''')

def generate_spring_boot_backend():
    """Generate Spring Boot backend files."""

    # pom.xml
    create_file('backend/pom.xml', '''<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.1</version>
        <relativePath/>
    </parent>

    <groupId>com.lumatalk</groupId>
    <artifactId>lumatalk-backend</artifactId>
    <version>1.0.0</version>
    <name>LumaTalk Backend</name>
    <description>Real-time translation backend service</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Flyway for database migrations -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>

        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
            <scope>runtime</scope>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- AWS S3 -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>s3</artifactId>
            <version>2.20.26</version>
        </dependency>

        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
''')

def generate_python_workers():
    """Generate Python inference worker files."""

    # ASR Worker
    create_file('inference/asr_worker/requirements.txt', '''fastapi==0.104.1
uvicorn[standard]==0.24.0
faster-whisper==0.10.0
torch==2.1.1
silero-vad==4.0.0
numpy==1.24.3
python-multipart==0.0.6
pydantic==2.5.0
websockets==12.0
''')

    create_file('inference/asr_worker/main.py', '''import asyncio
import logging
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from asr_service import ASRService
from vad_processor import VADProcessor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="LumaTalk ASR Worker")
asr_service = ASRService()
vad_processor = VADProcessor()

@app.on_event("startup")
async def startup_event():
    logger.info("Initializing ASR service...")
    await asr_service.initialize()
    logger.info("ASR service ready")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "asr_worker"}

@app.websocket("/ws/asr")
async def websocket_asr(websocket: WebSocket):
    await websocket.accept()
    logger.info("Client connected to ASR WebSocket")

    try:
        while True:
            # Receive audio data
            audio_data = await websocket.receive_bytes()

            # Check VAD
            has_speech = vad_processor.process(audio_data)

            if has_speech:
                # Process with ASR
                async for result in asr_service.transcribe_streaming(audio_data):
                    await websocket.send_json(result)

    except WebSocketDisconnect:
        logger.info("Client disconnected from ASR WebSocket")
    except Exception as e:
        logger.error(f"Error in ASR WebSocket: {e}")
        await websocket.close(code=1011)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
''')

    # MT Worker
    create_file('inference/mt_worker/requirements.txt', '''fastapi==0.104.1
uvicorn[standard]==0.24.0
google-cloud-translate==3.12.1
azure-ai-translation-text==1.0.0
transformers==4.35.2
torch==2.1.1
pydantic==2.5.0
python-dotenv==1.0.0
''')

    create_file('inference/mt_worker/main.py', '''import os
import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from translation_service import TranslationService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="LumaTalk MT Worker")
translation_service = TranslationService()

class TranslationRequest(BaseModel):
    text: str
    source_lang: str
    target_lang: str

class TranslationResponse(BaseModel):
    translated_text: str
    source_lang: str
    target_lang: str
    confidence: float

@app.on_event("startup")
async def startup_event():
    logger.info("Initializing translation service...")
    await translation_service.initialize()
    logger.info("Translation service ready")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "mt_worker"}

@app.post("/translate", response_model=TranslationResponse)
async def translate(request: TranslationRequest):
    try:
        result = await translation_service.translate(
            text=request.text,
            source_lang=request.source_lang,
            target_lang=request.target_lang
        )
        return result
    except Exception as e:
        logger.error(f"Translation error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
''')

    # TTS Worker
    create_file('inference/tts_worker/requirements.txt', '''fastapi==0.104.1
uvicorn[standard]==0.24.0
azure-cognitiveservices-speech==1.32.1
elevenlabs==0.2.27
torch==2.1.1
torchaudio==2.1.1
pydantic==2.5.0
python-dotenv==1.0.0
numpy==1.24.3
''')

    create_file('inference/tts_worker/main.py', '''import logging
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from tts_service import TTSService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="LumaTalk TTS Worker")
tts_service = TTSService()

@app.on_event("startup")
async def startup_event():
    logger.info("Initializing TTS service...")
    await tts_service.initialize()
    logger.info("TTS service ready")

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "tts_worker"}

@app.websocket("/ws/tts")
async def websocket_tts(websocket: WebSocket):
    await websocket.accept()
    logger.info("Client connected to TTS WebSocket")

    try:
        while True:
            # Receive text to synthesize
            data = await websocket.receive_json()
            text = data.get("text")
            lang = data.get("lang", "en")
            voice = data.get("voice")

            # Stream TTS audio
            async for audio_chunk in tts_service.synthesize_streaming(text, lang, voice):
                await websocket.send_bytes(audio_chunk)

            # Send completion signal
            await websocket.send_json({"type": "tts_complete"})

    except WebSocketDisconnect:
        logger.info("Client disconnected from TTS WebSocket")
    except Exception as e:
        logger.error(f"Error in TTS WebSocket: {e}")
        await websocket.close(code=1011)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
''')

def generate_docker_compose():
    """Generate Docker Compose configuration."""

    create_file('docker-compose.yml', '''version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: lumatalk-postgres
    environment:
      POSTGRES_DB: lumatalk
      POSTGRES_USER: lumatalk
      POSTGRES_PASSWORD: changeme
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lumatalk"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    container_name: lumatalk-backend
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/lumatalk
      SPRING_DATASOURCE_USERNAME: lumatalk
      SPRING_DATASOURCE_PASSWORD: changeme
      ASR_WORKER_URL: http://asr_worker:8001
      MT_WORKER_URL: http://mt_worker:8002
      TTS_WORKER_URL: http://tts_worker:8003
    depends_on:
      - postgres
    restart: unless-stopped

  asr_worker:
    build: ./inference/asr_worker
    container_name: lumatalk-asr
    ports:
      - "8001:8001"
    volumes:
      - model_cache:/root/.cache
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

  mt_worker:
    build: ./inference/mt_worker
    container_name: lumatalk-mt
    ports:
      - "8002:8002"
    environment:
      GOOGLE_APPLICATION_CREDENTIALS: /app/credentials/gcp-key.json
    volumes:
      - ./credentials:/app/credentials:ro
    restart: unless-stopped

  tts_worker:
    build: ./inference/tts_worker
    container_name: lumatalk-tts
    ports:
      - "8003:8003"
    environment:
      AZURE_SPEECH_KEY: ${AZURE_SPEECH_KEY}
      AZURE_SPEECH_REGION: ${AZURE_SPEECH_REGION}
    restart: unless-stopped

  coturn:
    image: coturn/coturn:latest
    container_name: lumatalk-turn
    ports:
      - "3478:3478/tcp"
      - "3478:3478/udp"
      - "49152-65535:49152-65535/udp"
    environment:
      TURN_USERNAME: ${TURN_USERNAME:-turnuser}
      TURN_PASSWORD: ${TURN_PASSWORD:-turnpass}
    command:
      - "-n"
      - "--log-file=stdout"
      - "--listening-port=3478"
      - "--realm=lumatalk.com"
      - "--user=${TURN_USERNAME:-turnuser}:${TURN_PASSWORD:-turnpass}"
    restart: unless-stopped

volumes:
  postgres_data:
  model_cache:
''')

def generate_dockerfiles():
    """Generate Dockerfiles for all services."""

    # Backend Dockerfile
    create_file('backend/Dockerfile', '''FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN apk add --no-cache maven
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
''')

    # ASR Worker Dockerfile
    create_file('inference/asr_worker/Dockerfile', '''FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y \\
    build-essential \\
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8001
CMD ["python", "main.py"]
''')

    # MT Worker Dockerfile
    create_file('inference/mt_worker/Dockerfile', '''FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8002
CMD ["python", "main.py"]
''')

    # TTS Worker Dockerfile
    create_file('inference/tts_worker/Dockerfile', '''FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8003
CMD ["python", "main.py"]
''')

def main():
    print("LumaTalk Project Generator")
    print("=" * 50)

    print("\nGenerating Flutter models...")
    generate_flutter_models()

    print("\nGenerating Flutter database...")
    generate_flutter_database()

    print("\nGenerating Flutter services...")
    generate_flutter_services()

    print("\nGenerating Spring Boot backend...")
    generate_spring_boot_backend()

    print("\nGenerating Python inference workers...")
    generate_python_workers()

    print("\nGenerating Docker configuration...")
    generate_docker_compose()
    generate_dockerfiles()

    print("\n" + "=" * 50)
    print("Project structure generated successfully!")
    print("\nNext steps:")
    print("1. Run: cd flutter_app && flutter pub get")
    print("2. Run: flutter pub run build_runner build --delete-conflicting-outputs")
    print("3. Set up your .env files with API keys")
    print("4. Run: docker-compose up -d")
    print("5. Run: flutter run")

if __name__ == "__main__":
    main()
