"""Main FastAPI application for FastAPI Template."""

import logging
import sys
from typing import Dict

import uvicorn
from fastapi import FastAPI

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)

# Create FastAPI application
app = FastAPI(
    title="FastAPI Template",
    description="FastAPI Template",
    version="0.1.0",
)


@app.get("/")
async def root() -> Dict[str, str]:
    """Root endpoint.

    Returns:
        Dict with welcome message
    """
    return {"message": "Welcome to the FastAPI Template API"}


@app.get("/health")
async def health_check() -> Dict[str, str]:
    """Health check endpoint.

    Returns:
        Dict with status
    """
    return {"status": "healthy"}


def start() -> None:
    """Start the FastAPI server using uvicorn.

    This function is called when running 'poetry run api'.
    """
    uvicorn.run("fastapi-template.api.main:app", host="0.0.0.0", port=8020, reload=True)


if __name__ == "__main__":
    start()
