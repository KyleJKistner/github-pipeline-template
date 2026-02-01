#!/usr/bin/env bash
set -euo pipefail

# Run linter and type checker
# Exit 0 on success, non-zero on failure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "==> Running linter..."
echo ""

LINT_FAILED=0

if [[ -f "package.json" ]]; then
    # Node.js project

    # Check for Biome
    if [[ -f "biome.json" ]] || [[ -f "biome.jsonc" ]]; then
        echo "==> Linting with Biome..."
        npx @biomejs/biome lint . || LINT_FAILED=1
    # Check for ESLint
    elif [[ -f ".eslintrc" ]] || [[ -f ".eslintrc.js" ]] || [[ -f ".eslintrc.json" ]] || [[ -f "eslint.config.js" ]] || [[ -f "eslint.config.mjs" ]]; then
        echo "==> Linting with ESLint..."
        npx eslint . || LINT_FAILED=1
    else
        echo "==> No linter configured (eslint or biome)"
        echo "    Consider adding eslint.config.js or biome.json"
    fi

    # TypeScript type checking
    if [[ -f "tsconfig.json" ]]; then
        echo ""
        echo "==> Type checking with TypeScript..."
        npx tsc --noEmit || LINT_FAILED=1
    fi

elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    # Python project

    # Ruff linting
    if command -v ruff &> /dev/null || [[ -f "pyproject.toml" ]]; then
        echo "==> Linting with Ruff..."
        ruff check . || LINT_FAILED=1
    fi

    # Type checking with mypy (if installed)
    if command -v mypy &> /dev/null; then
        echo ""
        echo "==> Type checking with mypy..."
        mypy . || LINT_FAILED=1
    elif command -v pyright &> /dev/null; then
        echo ""
        echo "==> Type checking with pyright..."
        pyright . || LINT_FAILED=1
    else
        echo ""
        echo "==> No type checker found (mypy or pyright)"
        echo "    Consider adding: pip install mypy"
    fi

else
    echo "==> No linter configured"
    echo ""
    echo "This is a template repository. To add linting:"
    echo ""
    echo "  For Node.js projects:"
    echo "    npm install --save-dev eslint"
    echo "    npx eslint --init"
    echo ""
    echo "  For Python projects:"
    echo "    pip install ruff mypy"
    echo ""
fi

echo ""

if [[ $LINT_FAILED -ne 0 ]]; then
    echo "==> Linting failed!"
    exit 1
fi

echo "==> Linting complete!"
