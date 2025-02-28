"""Tests for the main module."""

from fastapi_template.__main__ import main


def test_main():
    """Test that the main function returns 0."""
    assert main([]) == 0
