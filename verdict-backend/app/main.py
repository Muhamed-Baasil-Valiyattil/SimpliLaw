from fastapi import FastAPI
from app.routers import auth, summarize
import app.config
import firebase_admin
from google.cloud import firestore

app = FastAPI()
app.include_router(auth.router)
app.include_router(summarize.router)

firebase_admin.initialize_app()


@app.get("/")
async def root():
    return {
            "Current App Name:":firebase_admin.get_app().project_id,
            "message": "Welcome to the SimpliLaw Backend API"}

