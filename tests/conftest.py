"""Pytest configuration file."""

import pytest
from fastapi.testclient import TestClient

from fastapi_template.api.main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI application."""
    return TestClient(app)
