from fastapi import APIRouter

router = APIRouter()

@router.post("/summarize")
async def summarize(text: str):
    summary = "This is a placeholder summary."
    return {"summary": summary}
