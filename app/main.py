from fastapi import FastAPI
from app.routes import authorize
from app.database import init_db
from app import models
from dotenv import load_dotenv
load_dotenv()
app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # lub ["http://localhost:3000"] jeśli chcesz dokładnie
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],  # jawnie podane metody
    allow_headers=["*"],
)

@app.on_event("startup")
def startup():
    init_db()

app.include_router(authorize.router, prefix="/api")
