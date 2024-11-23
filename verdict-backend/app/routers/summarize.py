from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from transformers import pipeline
from app.routers.auth import get_firebase_user_from_token
from pydantic import BaseModel
from app.config import db

summarizer = pipeline("summarization", model="t5-small")

router = APIRouter()

class SummarizationRequest(BaseModel):
    text: str

@router.post("/summarize")
async def summarize(request: SummarizationRequest, token=Depends(get_firebase_user_from_token)):
    user_id = token.get("uid")
    result=summarizer(request.text,max_length=150,min_length=30,do_sample=False)

    summary_data = {
        "input_text": request.text,
        "summary_text": result[0]['summary_text'],
        "timestamp": datetime.utcnow(),
    }

    # Add summary data to Firestore
    try:
        db.collection("users").document(user_id).collection("summaries").add(summary_data)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to save summary: {str(e)}"
        )

    return {
            "user_id": user_id,
            "summary": result[0]['summary_text']
            }

@router.get("/summaries")
async def get_user_summaries(token=Depends(get_firebase_user_from_token)):
    user_id = token.get("uid")

    # Query the subcollection for summaries under the user's document
    summaries = db.collection("users").document(user_id).collection("summaries").stream()

    # Convert the results into a list
    summary_list = [
        {"id": doc.id, **doc.to_dict()} for doc in summaries
    ]

    return {"user_id": user_id, "summaries": summary_list}