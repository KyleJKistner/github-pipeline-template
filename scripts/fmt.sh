#!/usr/bin/env bash
set -euo pipefail

# Format code
# Usage: fmt.sh [--check]
#   --check: Verify formatting without modifying files (for CI)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHECK_ONLY="${1:-}"

cd "$PROJECT_ROOT"

echo "==> Running formatter..."
echo ""

if [[ -f "package.json" ]]; then
    # Node.js project - use prettier or biome
    if [[ -f "biome.json" ]] || [[ -f "biome.jsonc" ]]; then
        # Biome
        if [[ "$CHECK_ONLY" == "--check" ]]; then
            echo "==> Checking format with Biome..."
            npx @biomejs/biome check --linter-enabled=false .
        else
            echo "==> Formatting with Biome..."
            npx @biomejs/biome check --linter-enabled=false --apply .
        fi
    elif [[ -f ".prettierrc" ]] || [[ -f ".prettierrc.json" ]] || [[ -f "prettier.config.js" ]] || [[ -f "prettier.config.mjs" ]]; then
        # Prettier with config
        if [[ "$CHECK_ONLY" == "--check" ]]; then
            echo "==> Checking format with Prettier..."
            npx prettier --check .
        else
            echo "==> Formatting with Prettier..."
            npx prettier --write .
        fi
    else
        # Default: try prettier
        if [[ "$CHECK_ONLY" == "--check" ]]; then
            echo "==> Checking format with Prettier (using defaults)..."
            npx prettier --check "**/*.{js,jsx,ts,tsx,json,md,yml,yaml}" || {
                echo ""
                echo "NOTE: No prettier config found. Consider adding .prettierrc"
                exit 1
            }
        else
            echo "==> Formatting with Prettier (using defaults)..."
            npx prettier --write "**/*.{js,jsx,ts,tsx,json,md,yml,yaml}"
        fi
    fi

elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    # Python project - use ruff or black
    if command -v ruff &> /dev/null || [[ -f "pyproject.toml" ]]; then
        if [[ "$CHECK_ONLY" == "--check" ]]; then
            echo "==> Checking format with Ruff..."
            ruff format --check .
        else
            echo "==> Formatting with Ruff..."
            ruff format .
        fi
    elif command -v black &> /dev/null; then
        if [[ "$CHECK_ONLY" == "--check" ]]; then
            echo "==> Checking format with Black..."
            black --check .
        else
            echo "==> Formatting with Black..."
            black .
        fi
    else
        echo "ERROR: No Python formatter found"
        echo "Please install ruff: pip install ruff"
        exit 1
    fi

else
    echo "==> No formatter configured"
    echo ""
    echo "This is a template repository. To add formatting:"
    echo ""
    echo "  For Node.js projects:"
    echo "    npm install --save-dev prettier"
    echo "    echo '{}' > .prettierrc"
    echo ""
    echo "  For Python projects:"
    echo "    pip install ruff"
    echo "    # Ruff config goes in pyproject.toml"
    echo ""

    # In check mode, this is an error; in format mode, it's just informational
    if [[ "$CHECK_ONLY" == "--check" ]]; then
        exit 0  # No formatter = nothing to check = pass
    fi
fi

echo ""
echo "==> Formatting complete!"
