FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Configure poetry to not create virtual environments
# since Docker containers are isolated by design
RUN poetry config virtualenvs.create false

# Copy project files needed for installation
COPY pyproject.toml poetry.lock* README.md ./
COPY src ./src

# Install dependencies
RUN poetry install --without dev --no-interaction --no-ansi

# Copy the rest of the application code
COPY . .

# Expose the port the app will run on
EXPOSE 8020

# Command to run the application
CMD ["poetry", "run", "api"]
