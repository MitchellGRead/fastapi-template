#!/usr/bin/env python3
"""
Script to rename the FastAPI template project to a custom name.

Usage: python rename_project.py <new-project-name>
Example: python rename_project.py my-awesome-api
"""

import os
import shutil
import subprocess
import sys


def snake_case(name):
    """Convert kebab-case to snake_case."""
    return name.replace("-", "_")


def title_case(name):
    """Convert kebab-case to Title Case."""
    return " ".join(word.capitalize() for word in name.split("-"))


def run_command(command):
    """Run a shell command and return the output."""
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if result.returncode != 0:
        print(f"Error running command: {command}")
        print(result.stderr)
        sys.exit(1)
    return result.stdout.strip()


def rename_files_and_directories(old_name, new_name):
    """Rename files and directories containing the old name."""
    # Find all files and directories with the old name
    files_to_rename = run_command(f"find . -name '*{old_name}*' -not -path '*/\\.*' -not -path '*/venv/*'").split("\n")

    for file_path in files_to_rename:
        if not file_path:
            continue

        new_path = file_path.replace(old_name, new_name)
        if file_path != new_path:
            # Create parent directories if they don't exist
            os.makedirs(os.path.dirname(new_path), exist_ok=True)

            # Rename the file or directory
            os.rename(file_path, new_path)
            print(f"Renamed: {file_path} -> {new_path}")


def replace_content_in_files(old_kebab, old_snake, old_title, new_kebab, new_snake, new_title):
    """Replace content in all files."""
    # Find all files with the old names in their content
    files_with_content = set()

    # Get files with kebab-case name
    kebab_files = run_command(f"git grep -l '{old_kebab}' || true").split("\n")
    files_with_content.update(f for f in kebab_files if f)

    # Get files with snake_case name
    snake_files = run_command(f"git grep -l '{old_snake}' || true").split("\n")
    files_with_content.update(f for f in snake_files if f)

    # Get files with Title Case name
    title_files = run_command(f"git grep -l '{old_title}' || true").split("\n")
    files_with_content.update(f for f in title_files if f)

    for file_path in files_with_content:
        if not os.path.isfile(file_path):
            continue

        try:
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read()

            # Replace all instances of the old names
            new_content = content.replace(old_kebab, new_kebab)
            new_content = new_content.replace(old_snake, new_snake)
            new_content = new_content.replace(old_title, new_title)

            if content != new_content:
                with open(file_path, "w", encoding="utf-8") as file:
                    file.write(new_content)
                print(f"Updated content in: {file_path}")
        except UnicodeDecodeError:
            print(f"Skipping binary file: {file_path}")


def reinstall_dependencies():
    """Reinstall dependencies after renaming the project."""
    # Clean up virtual environment and lock file
    venv_path = ".venv"
    lock_path = "poetry.lock"

    print("Removing old virtual environment and lock file...")
    if os.path.exists(venv_path):
        shutil.rmtree(venv_path)
        print(f"Removed virtual environment: {venv_path}")

    if os.path.exists(lock_path):
        os.remove(lock_path)
        print(f"Removed lock file: {lock_path}")

    if os.path.exists("./poetry.lock"):
        os.remove("./poetry.lock")
        print("Removed ./poetry.lock")


def main():
    """Rename the project to a new name provided as a command line argument."""
    if len(sys.argv) != 2:
        print("Usage: python rename_project.py <new-project-name>")
        print("Example: python rename_project.py my-awesome-api")
        sys.exit(1)

    new_name_kebab = sys.argv[1]
    new_name_snake = snake_case(new_name_kebab)
    new_name_title = title_case(new_name_kebab)

    old_name_kebab = "fastapi-template"
    old_name_snake = "fastapi_template"
    old_name_title = "FastAPI Template"

    print(f"Renaming project from '{old_name_kebab}' to '{new_name_kebab}'")

    # Replace content in files first (before renaming directories)
    replace_content_in_files(
        old_name_kebab,
        old_name_snake,
        old_name_title,
        new_name_kebab,
        new_name_snake,
        new_name_title,
    )

    # Rename files and directories
    rename_files_and_directories(old_name_snake, new_name_snake)

    reinstall_dependencies()

    print("\nProject renamed successfully!")
    print(f"Old name: {old_name_kebab} / {old_name_snake} / {old_name_title}")
    print(f"New name: {new_name_kebab} / {new_name_snake} / {new_name_title}")

    print("Install new dependencies by running 'poetry install'")


if __name__ == "__main__":
    main()
