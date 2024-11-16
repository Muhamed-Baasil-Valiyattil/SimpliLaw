from fastapi import FastAPI
from app.routers import auth,summarization

app=FastAPI()

app.include_router(auth.router)
app.include_router(summarization.router)
@app.get("/")
async def root():
    return {"message": "Welcome to the SimpliLaw Backend API"}

