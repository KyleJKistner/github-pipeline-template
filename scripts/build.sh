#!/usr/bin/env bash
set -euo pipefail

# Build project artifacts
# Outputs to artifacts/dist directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"
DIST_DIR="$ARTIFACTS_DIR/dist"

cd "$PROJECT_ROOT"

echo "==> Running build..."
echo ""

# Ensure artifacts directory exists
mkdir -p "$DIST_DIR"

if [[ -f "package.json" ]]; then
    # Node.js project

    # Check for build script in package.json
    if grep -q '"build"' package.json 2>/dev/null; then
        echo "==> Running npm build..."
        npm run build

        # Copy dist output to artifacts if it exists elsewhere
        if [[ -d "dist" ]] && [[ "$(realpath dist)" != "$(realpath "$DIST_DIR")" ]]; then
            echo "==> Copying build output to artifacts..."
            cp -r dist/* "$DIST_DIR/" 2>/dev/null || true
        fi

    elif [[ -f "tsconfig.json" ]]; then
        echo "==> Compiling TypeScript..."
        npx tsc --outDir "$DIST_DIR"

    else
        echo "==> No build script found in package.json"
        echo "    Add a 'build' script or tsconfig.json for TypeScript projects"
        echo ""
        echo "==> Build skipped (nothing to build)"
    fi

elif [[ -f "pyproject.toml" ]]; then
    # Python project with pyproject.toml

    if command -v python -m build &> /dev/null || pip show build &> /dev/null 2>&1; then
        echo "==> Building Python package..."
        python -m build --outdir "$DIST_DIR"
    else
        echo "==> Python 'build' module not found"
        echo "    Install with: pip install build"
        echo ""
        echo "==> Build skipped"
    fi

elif [[ -f "setup.py" ]]; then
    # Legacy Python project
    echo "==> Building Python package (setup.py)..."
    python setup.py sdist bdist_wheel
    cp -r dist/* "$DIST_DIR/" 2>/dev/null || true

else
    echo "==> No build configuration found"
    echo ""
    echo "This is a template repository. To add a build step:"
    echo ""
    echo "  For Node.js projects:"
    echo "    Add a 'build' script to package.json"
    echo "    Or add tsconfig.json for TypeScript compilation"
    echo ""
    echo "  For Python projects:"
    echo "    Ensure pyproject.toml has [build-system] configured"
    echo "    pip install build"
    echo ""
    echo "==> Build skipped (nothing to build)"
fi

echo ""
echo "==> Build complete!"

# List build artifacts if any exist
if [[ -d "$DIST_DIR" ]] && [[ -n "$(ls -A "$DIST_DIR" 2>/dev/null)" ]]; then
    echo "    Build artifacts:"
    ls -la "$DIST_DIR"
else
    echo "    No build artifacts produced"
fi
