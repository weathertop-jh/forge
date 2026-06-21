"""Forge platform API."""

from fastapi import FastAPI

app = FastAPI(title="Forge API", version="0.1.0")


@app.get("/health")
async def health() -> dict[str, str]:
    """Return a lightweight process health signal."""
    return {"status": "ok", "service": "forge-api"}
