from pydantic import BaseSettings
from dotenv import load_dotenv
import os

load_dotenv()
class Settings(BaseSettings):
    secret_key: str = os.getenv("SECRET_KEY")
    database_url: str = os.getenv("DATABASE_URL")
    firebase_api_key: str = os.getenv("FIREBASE_API_KEY")


settings = Settings()