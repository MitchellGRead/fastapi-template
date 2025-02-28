"""Main entry point for the FastAPI Template."""

from typing import List, Optional


def main(args: Optional[List[str]] = None) -> int:
    """Run the main program.

    Args:
        args: Command line arguments

    Returns:
        Exit code
    """
    print("FastAPI Template is running!")
    return 0


if __name__ == "__main__":
    import sys

    sys.exit(main(sys.argv[1:]))
