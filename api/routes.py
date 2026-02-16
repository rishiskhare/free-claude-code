"""FastAPI route handlers."""

import json
import uuid
from pathlib import Path

from fastapi import APIRouter, Request, Depends, HTTPException
from loguru import logger
from fastapi.responses import JSONResponse, StreamingResponse

from .models.anthropic import MessagesRequest, TokenCountRequest
from .models.responses import TokenCountResponse
from .dependencies import get_provider, get_settings
from .request_utils import get_token_count
from .optimization_handlers import try_optimizations
from config.settings import Settings
from providers.base import BaseProvider
from providers.exceptions import ProviderError
from providers.logging_utils import build_request_summary, log_request_compact


router = APIRouter()

MODELS_FILE = Path(__file__).resolve().parent.parent / "nvidia_nim_models.json"


def _parse_model_override(raw_request: Request) -> str | None:
    """Extract model override from x-api-key header.

    Format: "freecc:org/model-name" → returns "org/model-name"
    "freecc" or "freecc:" → returns None (use default)
    """
    api_key = raw_request.headers.get("x-api-key", "")
    if ":" not in api_key:
        return None
    _, model = api_key.split(":", 1)
    return model.strip() or None


# =============================================================================
# Routes
# =============================================================================


@router.post("/v1/messages")
async def create_message(
    request_data: MessagesRequest,
    raw_request: Request,
    provider: BaseProvider = Depends(get_provider),
    settings: Settings = Depends(get_settings),
):
    """Create a message (always streaming)."""

    try:
        # Per-session model override via auth token (freecc:org/model-name)
        model_override = _parse_model_override(raw_request)
        if model_override:
            logger.info(f"Model override via token: {request_data.model} -> {model_override}")
            request_data.model = model_override

        optimized = try_optimizations(request_data, settings)
        if optimized is not None:
            return optimized

        request_id = f"req_{uuid.uuid4().hex[:12]}"
        log_request_compact(logger, request_id, request_data)

        input_tokens = get_token_count(
            request_data.messages, request_data.system, request_data.tools
        )
        return StreamingResponse(
            provider.stream_response(
                request_data,
                input_tokens=input_tokens,
                request_id=request_id,
            ),
            media_type="text/event-stream",
            headers={
                "X-Accel-Buffering": "no",
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            },
        )

    except ProviderError:
        raise
    except Exception as e:
        import traceback

        logger.error(f"Error: {str(e)}\n{traceback.format_exc()}")
        raise HTTPException(status_code=getattr(e, "status_code", 500), detail=str(e))


@router.post("/v1/messages/count_tokens")
async def count_tokens(request_data: TokenCountRequest):
    """Count tokens for a request."""
    request_id = f"req_{uuid.uuid4().hex[:12]}"
    with logger.contextualize(request_id=request_id):
        try:
            tokens = get_token_count(
                request_data.messages, request_data.system, request_data.tools
            )
            summary = build_request_summary(request_data)
            summary["request_id"] = request_id
            summary["input_tokens"] = tokens
            logger.info("COUNT_TOKENS: %s", json.dumps(summary))
            return TokenCountResponse(input_tokens=tokens)
        except Exception as e:
            import traceback

            logger.error(
                "COUNT_TOKENS_ERROR: request_id=%s error=%s\n%s",
                request_id,
                str(e),
                traceback.format_exc(),
            )
            raise HTTPException(status_code=500, detail=str(e))


@router.get("/v1/models")
async def list_models():
    """Return available NVIDIA NIM models from nvidia_nim_models.json."""
    try:
        data = json.loads(MODELS_FILE.read_text())
        return JSONResponse(content=data)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="nvidia_nim_models.json not found")
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Invalid JSON in nvidia_nim_models.json")


@router.get("/")
async def root(settings: Settings = Depends(get_settings)):
    """Root endpoint."""
    return {
        "status": "ok",
        "provider": "nvidia_nim",
        "model": settings.model,
    }


@router.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "healthy"}


@router.post("/stop")
async def stop_cli(request: Request):
    """Stop all CLI sessions and pending tasks."""
    handler = getattr(request.app.state, "message_handler", None)
    if not handler:
        # Fallback if messaging not initialized
        cli_manager = getattr(request.app.state, "cli_manager", None)
        if cli_manager:
            await cli_manager.stop_all()
            logger.info("STOP_CLI: source=cli_manager cancelled_count=N/A")
            return {"status": "stopped", "source": "cli_manager"}
        raise HTTPException(status_code=503, detail="Messaging system not initialized")

    count = await handler.stop_all_tasks()
    logger.info("STOP_CLI: source=handler cancelled_count=%d", count)
    return {"status": "stopped", "cancelled_count": count}
