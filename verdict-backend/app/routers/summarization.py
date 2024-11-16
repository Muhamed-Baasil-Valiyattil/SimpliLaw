from pydantic import BaseModel
from fastapi import APIRouter
from transformers import pipeline

# Initialize the summarization pipeline using the T5 model
summarizer = pipeline("summarization", model="t5-small")

router = APIRouter()

class SummarizationRequest(BaseModel):
    text: str

@router.post("/summarize")
async def summarize(request: SummarizationRequest):

    result = summarizer(request.text, max_length=130, min_length=30, do_sample=False)
    return {"summary": result[0]['summary_text']}



