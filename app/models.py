from sqlalchemy import Column, String, DateTime
from app.base import Base
import uuid
from datetime import datetime

class ConnectedAccount(Base):
    __tablename__ = "connected_accounts"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, nullable=False)
    platform = Column(String, nullable=False)  # np. 'facebook'
    account_id = Column(String, nullable=False)
    account_name = Column(String, nullable=False)
    token = Column(String, nullable=False)
    token_expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
# Placeholder for SQLAlchemy models
