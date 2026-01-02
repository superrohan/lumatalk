import logging
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
