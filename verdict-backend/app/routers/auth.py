from typing import Annotated
from fastapi import APIRouter
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin.auth import verify_id_token

router = APIRouter()

bearer_scheme = HTTPBearer(auto_error=False)

def get_firebase_user_from_token(
    token: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],) -> dict | None:
    try:
        if not token:
            raise ValueError("No token")
        user = verify_id_token(token.credentials)
        return user
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not logged in or Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

@router.get("/status")
async def auth_status():
    return {"message": "Authentication service is operational"}

@router.get("/user")
async def get_user_info(user: Annotated[dict, Depends(get_firebase_user_from_token)]):
    return {"id": user["uid"]}