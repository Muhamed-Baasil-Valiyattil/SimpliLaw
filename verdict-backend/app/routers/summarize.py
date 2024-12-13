from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from transformers import pipeline
from app.routers.auth import get_firebase_user_from_token
from pydantic import BaseModel
from app.config import db
import PyPDF2
from docx import Document

summarizer = pipeline("summarization", model="t5-small")

router = APIRouter()

class SummarizationRequest(BaseModel):
    text: str

def generateSummary(text: str, user_id: str) -> str:
    # if not text or len(text.strip()) < 50:
    #     raise HTTPException(status_code=400, detail="Text must be at least 50 characters long")

    result = summarizer(text, max_length=150, min_length=30, do_sample=False)

    summary_data = {
        "input_text": text,
        "summary_text": result[0]['summary_text'],
        "timestamp": datetime.utcnow(),
    }

    try:
        db.collection("users").document(user_id).collection("summaries").add(summary_data)
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Failed to save summary: {str(e)}"
        )
    
    return result[0]['summary_text']

def extract_text_from_pdf(file) -> str:
    try:
        pdf_reader = PyPDF2.PdfReader(file)
        text = ""
        for page in pdf_reader.pages:
            text += page.extract_text()
        return text
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading PDF: {str(e)}")

def extract_text_from_docx(file) -> str:
    try:
        doc = Document(file)
        text = "\n".join(para.text for para in doc.paragraphs if para.text)
        return text
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading DOCX: {str(e)}")

def extract_text_from_txt(file) -> str:
    try:
        return file.read().decode("utf-8")
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error reading TXT file: {str(e)}")

@router.post("/upload")
async def upload_and_summarize(
    file: UploadFile = File(...),
    token=Depends(get_firebase_user_from_token)
):
    user_id = token.get("uid")

    if file.filename.lower().endswith(".pdf"):
        text = extract_text_from_pdf(file.file)
    elif file.filename.lower().endswith(".docx"):
        text = extract_text_from_docx(file.file)
    elif file.filename.lower().endswith(".txt"):
        text = extract_text_from_txt(file.file)
    else:
        raise HTTPException(status_code=400, detail="Unsupported file format. Supports .pdf, .docx, .txt")

    summary = generateSummary(text, user_id)
    return {
        "user_id": user_id,
        "filename": file.filename,
        "summary": summary
    }

@router.post("/summarize")
async def summarize_text(
    request: SummarizationRequest, 
    token=Depends(get_firebase_user_from_token)
):
    user_id = token.get("uid")

    summary = generateSummary(request.text, user_id)
    return {
        "user_id": user_id,
        "summary": summary
    }

@router.get("/summaries")
async def get_user_summaries(token=Depends(get_firebase_user_from_token)):
    user_id = token.get("uid")

    summaries = db.collection("users").document(user_id).collection("summaries").stream()
    summary_list = [
        {"id": doc.id, **doc.to_dict()} for doc in summaries
    ]

    return {"user_id": user_id, "summaries": summary_list}