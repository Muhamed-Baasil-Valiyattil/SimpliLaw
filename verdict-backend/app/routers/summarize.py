from fastapi import APIRouter, Depends
from transformers import pipeline
from app.routers.auth import get_firebase_user_from_token
from pydantic import BaseModel

summarizer = pipeline("summarization", model="t5-small")

router = APIRouter()

class SummarizationRequest(BaseModel):
    text: str

@router.post("/summarize")
async def summarize(request: SummarizationRequest, token=Depends(get_firebase_user_from_token)):
    user_id = token.get("uid")
    result=summarizer(request.text,max_length=150,min_length=30,do_sample=False)

    return {
            "user_id": user_id,
            "summary": result[0]['summary_text']
            }