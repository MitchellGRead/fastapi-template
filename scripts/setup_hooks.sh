#!/bin/bash

# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

echo -e "${YELLOW}Setting up pre-commit hooks...${NC}"

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}Error: Poetry is not installed. Please install Poetry first.${NC}"
    exit 1
fi

# Install pre-commit if not already installed
if ! poetry run pre-commit --version &> /dev/null; then
    echo -e "${YELLOW}Installing pre-commit...${NC}"
    poetry add --group dev pre-commit
fi

# Install the pre-commit hooks
echo -e "${YELLOW}Installing git hooks...${NC}"
poetry run pre-commit install

echo -e "${GREEN}Pre-commit hooks installed successfully!${NC}"
echo -e "${YELLOW}The following checks will run before each commit:${NC}"
echo -e "  - trailing-whitespace: Removes trailing whitespace"
echo -e "  - end-of-file-fixer: Ensures files end with a newline"
echo -e "  - check-yaml: Validates YAML files"
echo -e "  - check-added-large-files: Prevents large files from being committed"
echo -e "  - black: Formats Python code"
echo -e "  - isort: Sorts imports"
echo -e "  - flake8: Checks for PEP 8 compliance and code quality"
echo -e "  - mypy: Performs static type checking"

echo -e "\n${YELLOW}You can run the checks manually with:${NC}"
echo -e "  poetry run pre-commit run --all-files"
