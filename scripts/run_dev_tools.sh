#!/bin/bash

# Exit on any error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

# Parse command line arguments
SKIP_TESTS=false
SKIP_MYPY=false
FIX=false

usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -f, --fix       Fix issues where possible (run formatters in write mode)"
    echo "  --skip-tests    Skip running tests"
    echo "  --skip-mypy     Skip running mypy"
    echo "  -h, --help      Show this help message"
    echo
    echo "Example:"
    echo "  $0              # Run all checks"
    echo "  $0 --fix        # Run formatters in write mode and other checks"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--fix) FIX=true ;;
        --skip-tests) SKIP_TESTS=true ;;
        --skip-mypy) SKIP_MYPY=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; usage; exit 1 ;;
    esac
    shift
done

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}Error: Poetry is not installed. Please install Poetry first.${NC}"
    exit 1
fi

# Function to run a command with nice formatting
run_step() {
    local cmd="$1"
    local description="$2"

    echo -e "\n${BLUE}=== $description ===${NC}"
    echo -e "${YELLOW}Running: $cmd${NC}"

    if eval "$cmd"; then
        echo -e "${GREEN}✓ Success!${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed!${NC}"
        return 1
    fi
}

# Main execution
echo -e "${BLUE}Starting code quality checks...${NC}"

# Determine black and isort mode
if [ "$FIX" = true ]; then
    BLACK_ARGS=""
    ISORT_ARGS=""
    echo -e "${YELLOW}Running in FIX mode - will modify files${NC}"
else
    BLACK_ARGS="--check"
    ISORT_ARGS="--check"
    echo -e "${YELLOW}Running in CHECK mode - will not modify files${NC}"
fi

# Run black
run_step "poetry run black $BLACK_ARGS ." "Checking code formatting with black"

# Run isort
run_step "poetry run isort $ISORT_ARGS ." "Checking import sorting with isort"

# Run flake8
run_step "poetry run flake8 src tests" "Checking code style with flake8"

# Run mypy if not skipped
if [ "$SKIP_MYPY" = false ]; then
    run_step "poetry run mypy src" "Checking types with mypy"
else
    echo -e "\n${YELLOW}Skipping mypy checks${NC}"
fi

# Run tests if not skipped
if [ "$SKIP_TESTS" = false ]; then
    run_step "poetry run pytest" "Running tests with pytest"
else
    echo -e "\n${YELLOW}Skipping tests${NC}"
fi

echo -e "\n${GREEN}All checks completed successfully!${NC}"
