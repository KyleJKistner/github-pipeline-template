#!/usr/bin/env bash
set -euo pipefail

# CI Pipeline - runs all checks in sequence
# This produces identical results locally and in GitHub Actions
#
# Pipeline: fmt-check → lint → test → build

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "========================================"
echo "  CI Pipeline"
echo "========================================"
echo ""
echo "Project: $(basename "$PROJECT_ROOT")"
echo "Directory: $PROJECT_ROOT"
echo "Date: $(date)"
echo ""

# Track timing
START_TIME=$(date +%s)

# Step 1: Format check
echo "========================================"
echo "  Step 1/4: Format Check"
echo "========================================"
echo ""
"$SCRIPT_DIR/fmt.sh" --check
echo ""

# Step 2: Lint
echo "========================================"
echo "  Step 2/4: Lint"
echo "========================================"
echo ""
"$SCRIPT_DIR/lint.sh"
echo ""

# Step 3: Test
echo "========================================"
echo "  Step 3/4: Test"
echo "========================================"
echo ""
"$SCRIPT_DIR/test.sh"
echo ""

# Step 4: Build
echo "========================================"
echo "  Step 4/4: Build"
echo "========================================"
echo ""
"$SCRIPT_DIR/build.sh"
echo ""

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "========================================"
echo "  CI Pipeline Complete!"
echo "========================================"
echo ""
echo "Duration: ${DURATION}s"
echo ""
echo "Artifacts:"
if [[ -d "$PROJECT_ROOT/artifacts" ]]; then
    find "$PROJECT_ROOT/artifacts" -type f | head -20 | while read -r file; do
        echo "  - ${file#$PROJECT_ROOT/}"
    done
    ARTIFACT_COUNT=$(find "$PROJECT_ROOT/artifacts" -type f | wc -l | tr -d ' ')
    if [[ "$ARTIFACT_COUNT" -gt 20 ]]; then
        echo "  ... and $((ARTIFACT_COUNT - 20)) more"
    fi
else
    echo "  (none)"
fi
echo ""
