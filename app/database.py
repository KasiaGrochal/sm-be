from sqlalchemy import create_engine
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://sm_admin:supersecure@db:5432/sm_assistant")
engine = create_engine(DATABASE_URL)

def init_db():
    # Placeholder for future DB init
    pass
