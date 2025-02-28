# Welcome

This is a python template for a FastAPI service. This template includes things such as:
- Poetry for dependency management
- Docker for containerization and docker-compose for deployment
- Utility scripts for [dev tool](#development-tools) execution and [deployment testing](#docker-deployment)
- Pre-commit hooks for code quality checks

Currently, this template is version 0.1.0 so things may not all work fully as expected but any suggestions are welcome!

## Project Structure

This project follows the src layout pattern for Python packages:

```
fastapi-template/
├── .github/                        # GitHub Actions configuration
├── scripts/                        # Utility scripts
├── src/
│   └── fastapi-template/           # Main package code
│       ├── __init__.py
│       ├── __main__.py
│       └── api/                      # FastAPI service
│           ├── __init__.py
│           └── main.py
├── tests/                          # Test files
├── pyproject.toml                  # Poetry configuration
├── README.md
├── Dockerfile
├── docker-compose.yml
└── .env.example
```

## Development

This project uses [Poetry](https://python-poetry.org/) for dependency management.

### Setup

1. Install Poetry (if not already installed):
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. Install dependencies:
   ```bash
   poetry install
   ```

### Running the Package

```bash
# Run directly with Poetry
poetry run python -m fastapi-template

# Or after activating the virtual environment
python -m fastapi-template
```

### Running the FastAPI Service

The project includes an initial FastAPI service:

```bash
# Run the API server with Poetry
poetry run api

# Or after activating the virtual environment
python -m fastapi-template.api.main
```

Once the service is running, you can:
- Access the API documentation at http://localhost:8020/docs
- Access the alternative documentation at http://localhost:8020/redoc

### Docker Deployment

The project includes Docker configuration for easy deployment:

```bash
# Build and start the Docker container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down

# Rebuild the container
docker-compose build --no-cache
```

The API will be available at http://localhost:8020.

### Available API Endpoints

- `GET /`: Welcome message
- `GET /health`: Health check endpoint

### Development Tools

This project is configured with several development tools:

- **pytest**: For running tests
- **black**: For code formatting
- **isort**: For import sorting
- **flake8**: For linting
- **mypy**: For type checking
- **pre-commit**: For running checks before each commit

Run these tools with Poetry:

```bash
poetry run black .
poetry run isort .
poetry run flake8 src tests
poetry run mypy src
poetry run pytest
```

Or use the provided script to run all checks at once:

```bash
# Run all checks in check mode (won't modify files)
./scripts/run-dev-tools.sh

# Run formatters in fix mode (will modify files) and other checks
./scripts/run-dev-tools.sh --fix

# Skip specific checks
./scripts/run-dev-tools.sh --skip-tests --skip-mypy
```

### Pre-commit Hooks

This project uses pre-commit hooks to ensure code quality. To set up the hooks:

1. Install the git hooks:
```bash
  ./scripts/setup_hooks.sh
```

2. The hooks will now run automatically on every commit. You can also run them manually:
```bash
  poetry run pre-commit run --all-files
```

The following checks will run before each commit:
- trailing-whitespace: Removes trailing whitespace
- end-of-file-fixer: Ensures files end with a newline
- check-yaml: Validates YAML files
- check-added-large-files: Prevents large files from being committed
- black: Formats Python code
- isort: Sorts imports
- flake8: Checks for PEP 8 compliance and code quality
- mypy: Performs static type checking
