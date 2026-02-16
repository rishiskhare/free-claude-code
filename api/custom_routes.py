"""Custom routes for free-claude-code fork.

This module contains custom endpoints that are specific to this fork
(claude-free model picker, per-session model overrides).
These are kept separate from upstream code to avoid merge conflicts.
"""

import json
from pathlib import Path
from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse

router = APIRouter()

MODELS_FILE = Path(__file__).resolve().parent.parent / "nvidia_nim_models.json"


def _parse_model_override(api_key: str) -> str | None:
    """Extract model override from auth token.

    Format: "freecc:org/model-name" → returns "org/model-name"
    "freecc" or "freecc:" → returns None (use default from settings)
    """
    if ":" not in api_key:
        return None
    _, model = api_key.split(":", 1)
    return model.strip() or None


@router.get("/v1/models")
async def list_models():
    """Return available NVIDIA NIM models from nvidia_nim_models.json.

    Used by the claude-free model picker script.
    """
    try:
        data = json.loads(MODELS_FILE.read_text())
        return JSONResponse(content=data)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="nvidia_nim_models.json not found")
    except json.JSONDecodeError:
        raise HTTPException(
            status_code=500, detail="Invalid JSON in nvidia_nim_models.json"
        )
