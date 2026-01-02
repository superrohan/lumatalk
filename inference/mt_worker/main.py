import os
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
