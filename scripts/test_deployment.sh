#!/bin/bash

# Exit on any error
set -e

# Colors for output (disable if CI detected)
if [ -n "$CI" ]; then
    GREEN=''
    RED=''
    NC=''
    YELLOW=''
else
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
    YELLOW='\033[1;33m'
fi

# Default values
API_PORT="${API_PORT:-8020}"
API_HOST="${API_HOST:-localhost}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-60}"
CURL_TIMEOUT="${CURL_TIMEOUT:-10}"

# Determine docker compose command to use (V1 or V2)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}Error: Neither docker-compose nor docker compose is available${NC}"
    exit 1
fi

# Print usage information
usage() {
    echo "Usage: $0 [-c|--cleanup]"
    echo
    echo "Options:"
    echo "  -c, --cleanup    Clean up containers after tests complete"
    echo "  -h, --help       Show this help message"
    echo
    echo "Example:"
    echo "  $0              # Run tests and keep containers running"
    echo "  $0 --cleanup    # Run tests and clean up containers afterwards"
}

# Parse command line arguments
CLEANUP=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--cleanup) CLEANUP=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; usage; exit 1 ;;
    esac
    shift
done

echo -e "${YELLOW}Starting deployment test...${NC}"

# Function to check if curl is installed
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is not installed. Please install curl to continue.${NC}"
        exit 1
    fi
}

# Function to wait for service to be ready
wait_for_service() {
    local retries=$((WAIT_TIMEOUT / 2))
    local wait_time=2
    local endpoint="$1"
    local message="$2"

    echo -e "${YELLOW}$message${NC}"

    for i in $(seq 1 $retries); do
        if curl -s --max-time $CURL_TIMEOUT "$endpoint" > /dev/null; then
            echo -e "${GREEN}Service is ready!${NC}"
            return 0
        fi
        echo -n "."
        sleep $wait_time
    done

    echo -e "\n${RED}Service failed to become ready within ${WAIT_TIMEOUT} seconds${NC}"
    return 1
}

# Function to test API endpoints
test_endpoints() {
    local base_url="$1"
    local errors=0

    # Test health endpoint
    echo -e "\n${YELLOW}Testing health endpoint...${NC}"
    response=$(curl -s --max-time $CURL_TIMEOUT "${base_url}/health")
    if [[ "$response" == *"healthy"* ]]; then
        echo -e "${GREEN}Health check passed${NC}"
    else
        echo -e "${RED}Health check failed${NC}"
        ((errors++))
    fi

    # Test root endpoint
    echo -e "\n${YELLOW}Testing root endpoint...${NC}"
    response=$(curl -s --max-time $CURL_TIMEOUT "${base_url}/")
    if [[ "$response" == *"Welcome"* ]]; then
        echo -e "${GREEN}Root endpoint check passed${NC}"
    else
        echo -e "${RED}Root endpoint check failed${NC}"
        ((errors++))
    fi

    return $errors
}

main() {
    local api_url="http://${API_HOST}:${API_PORT}"

    # Check for curl
    check_curl

    echo -e "\n${YELLOW}Stopping any existing containers...${NC}"
    $DOCKER_COMPOSE down --remove-orphans

    echo -e "\n${YELLOW}Building containers...${NC}"
    if ! $DOCKER_COMPOSE build --no-cache; then
        echo -e "${RED}Build failed${NC}"
        exit 1
    fi

    echo -e "\n${YELLOW}Starting containers...${NC}"
    if ! $DOCKER_COMPOSE up -d; then
        echo -e "${RED}Container startup failed${NC}"
        exit 1
    fi

    # Wait for service to be ready
    if ! wait_for_service "${api_url}/health" "Waiting for API to be ready..."; then
        echo -e "${RED}Service failed to start${NC}"
        $DOCKER_COMPOSE logs
        $DOCKER_COMPOSE down
        exit 1
    fi

    # Test endpoints
    if ! test_endpoints "$api_url"; then
        echo -e "\n${RED}Endpoint tests failed${NC}"
        $DOCKER_COMPOSE logs
        $DOCKER_COMPOSE down
        exit 1
    fi

    echo -e "\n${GREEN}All tests passed successfully!${NC}"

    # Clean up if requested
    if [[ "$CLEANUP" == "true" ]]; then
        echo -e "\n${YELLOW}Cleaning up containers...${NC}"
        $DOCKER_COMPOSE down --remove-orphans
    else
        echo -e "\n${YELLOW}Containers are still running. Use '$DOCKER_COMPOSE down' to stop them.${NC}"
    fi
}

main
