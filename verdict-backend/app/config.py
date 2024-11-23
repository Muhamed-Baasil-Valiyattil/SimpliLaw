import os
import pathlib
from functools import lru_cache
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

basedir = pathlib.Path(__file__).parents[1]
load_dotenv(basedir / ".env")

import firebase_admin
from google.cloud import firestore

firebase_admin.initialize_app()
db = firestore.Client()

class Settings(BaseSettings):
    app_name: str = "simplilaw"
    env: str = os.getenv("ENV", "development")

@lru_cache
def get_settings() -> Settings:
    return Settings()