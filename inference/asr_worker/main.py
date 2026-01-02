import asyncio
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
