#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script - sets up local development environment
# This script should be idempotent (safe to run multiple times)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "==> Running bootstrap..."
echo ""

cd "$PROJECT_ROOT"

# Create artifacts directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/artifacts"

# Detect project type and install dependencies
if [[ -f "package.json" ]]; then
    echo "==> Detected Node.js project"

    # Check for Node.js
    if ! command -v node &> /dev/null; then
        echo "ERROR: Node.js is not installed"
        echo "Please install Node.js 20+ from https://nodejs.org/"
        exit 1
    fi

    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
    echo "    Node.js version: $(node --version)"

    if [[ "$NODE_VERSION" -lt 20 ]]; then
        echo "WARNING: Node.js 20+ is recommended (found v$NODE_VERSION)"
    fi

    # Install dependencies with preferred package manager
    if [[ -f "pnpm-lock.yaml" ]] && command -v pnpm &> /dev/null; then
        echo "==> Installing dependencies with pnpm..."
        pnpm install --frozen-lockfile
    elif [[ -f "yarn.lock" ]] && command -v yarn &> /dev/null; then
        echo "==> Installing dependencies with yarn..."
        yarn install --frozen-lockfile
    elif [[ -f "package-lock.json" ]] || command -v npm &> /dev/null; then
        echo "==> Installing dependencies with npm..."
        npm ci
    else
        echo "ERROR: No Node.js package manager found"
        echo "Please install npm, yarn, or pnpm"
        exit 1
    fi

elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    echo "==> Detected Python project"

    # Check for Python
    if ! command -v python3 &> /dev/null; then
        echo "ERROR: Python 3 is not installed"
        echo "Please install Python 3.11+ from https://python.org/"
        exit 1
    fi

    PYTHON_VERSION=$(python3 --version | sed 's/Python //' | cut -d. -f1,2)
    echo "    Python version: $(python3 --version)"

    # Install dependencies with preferred package manager
    if command -v uv &> /dev/null; then
        echo "==> Installing dependencies with uv..."
        if [[ -f "pyproject.toml" ]]; then
            uv sync
        else
            uv pip install -r requirements.txt
        fi
    elif command -v pip &> /dev/null; then
        echo "==> Installing dependencies with pip..."

        # Create virtual environment if it doesn't exist
        if [[ ! -d ".venv" ]]; then
            echo "==> Creating virtual environment..."
            python3 -m venv .venv
        fi

        # Activate and install
        source .venv/bin/activate
        pip install --upgrade pip

        if [[ -f "pyproject.toml" ]]; then
            pip install -e ".[dev]"
        else
            pip install -r requirements.txt
        fi
    else
        echo "ERROR: No Python package manager found"
        echo "Please install pip or uv"
        exit 1
    fi

else
    echo "==> No recognized project configuration found"
    echo ""
    echo "This is a template repository. To use it:"
    echo ""
    echo "  For Node.js projects:"
    echo "    1. Create package.json"
    echo "    2. Run: make bootstrap"
    echo ""
    echo "  For Python projects:"
    echo "    1. Create pyproject.toml or requirements.txt"
    echo "    2. Run: make bootstrap"
    echo ""
    echo "See README.md for more information."
fi

echo ""
echo "==> Bootstrap complete!"
