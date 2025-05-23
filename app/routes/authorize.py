import os
import httpx
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.database import get_db
from app.models import ConnectedAccount  # zakładamy, że masz ten model
from sqlalchemy.orm import Session
from dotenv import load_dotenv

load_dotenv()

router = APIRouter()

class AuthorizationRequest(BaseModel):
    code: str

@router.post("/authorize")
async def authorize(body: AuthorizationRequest):
    code = body.code
    print(code)
    client_id = os.getenv("META_CLIENT_ID")
    client_secret = os.getenv("META_CLIENT_SECRET")
    redirect_uri = os.getenv("META_REDIRECT_URI")

    # 1. Exchange code → short-lived token

    async with httpx.AsyncClient() as client:
        r = await client.get("https://graph.facebook.com/v19.0/oauth/access_token", params={
            "client_id": client_id,
            "redirect_uri": redirect_uri,
            "client_secret": client_secret,
            "code": code
        })
        print(client_id, redirect_uri, client_secret, code)
        if r.status_code != 200:
            raise HTTPException(status_code=400, detail=f"Error getting short-lived token: {r.text}")
        short_token = r.json()["access_token"]

    # 2. Exchange short-lived → long-lived token
    async with httpx.AsyncClient() as client:
        r = await client.get("https://graph.facebook.com/v19.0/oauth/access_token", params={
            "grant_type": "fb_exchange_token",
            "client_id": client_id,
            "client_secret": client_secret,
            "fb_exchange_token": short_token
        })
        if r.status_code != 200:
            raise HTTPException(status_code=400, detail=f"Error getting long-lived token: {r.text}")
        long_token_data = r.json()
        long_token = long_token_data["access_token"]
        expires_in = long_token_data.get("expires_in", 60 * 60 * 24 * 60)  # default 60 dni

    # 3. Get user (account) info
    async with httpx.AsyncClient() as client:
        r = await client.get("https://graph.facebook.com/v19.0/me", params={
            "fields": "id,name",
            "access_token": long_token
        })
        if r.status_code != 200:
            raise HTTPException(status_code=400, detail=f"Error getting account info: {r.text}")
        data = r.json()
        account_id = data["id"]
        account_name = data["name"]

    # 4. Save to DB
    db: Session = next(get_db())
    connected = ConnectedAccount(
        user_id="test_user_id",  # TODO: zamienić na realnego użytkownika
        platform="facebook",
        account_id=account_id,
        account_name=account_name,
        token=long_token,
        token_expires_at=datetime.utcnow() + timedelta(seconds=expires_in),
    )
    db.add(connected)
    db.commit()

    return {
        "message": "Authorization successful"
    }
