#!/usr/bin/env bash
set -euo pipefail

# Run tests and generate coverage reports
# Outputs to artifacts/ directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

cd "$PROJECT_ROOT"

echo "==> Running tests..."
echo ""

# Ensure artifacts directory exists
mkdir -p "$ARTIFACTS_DIR"
mkdir -p "$ARTIFACTS_DIR/coverage"
mkdir -p "$ARTIFACTS_DIR/test-results"

if [[ -f "package.json" ]]; then
    # Node.js project

    # Detect test runner
    if grep -q '"vitest"' package.json 2>/dev/null; then
        echo "==> Running tests with Vitest..."
        npx vitest run \
            --coverage \
            --coverage.reporter=json \
            --coverage.reporter=text \
            --coverage.reporter=html \
            --coverage.reportsDirectory="$ARTIFACTS_DIR/coverage" \
            --reporter=verbose \
            --reporter=junit \
            --outputFile.junit="$ARTIFACTS_DIR/test-results/junit.xml"

    elif grep -q '"jest"' package.json 2>/dev/null; then
        echo "==> Running tests with Jest..."
        npx jest \
            --coverage \
            --coverageDirectory="$ARTIFACTS_DIR/coverage" \
            --coverageReporters=json --coverageReporters=text --coverageReporters=html \
            --reporters=default \
            --reporters=jest-junit

        # Move junit report if it was created in default location
        if [[ -f "junit.xml" ]]; then
            mv junit.xml "$ARTIFACTS_DIR/test-results/"
        fi

    elif grep -q '"mocha"' package.json 2>/dev/null; then
        echo "==> Running tests with Mocha..."
        npx nyc --reporter=json --reporter=text --reporter=html \
            --report-dir="$ARTIFACTS_DIR/coverage" \
            mocha --reporter mocha-junit-reporter \
            --reporter-options mochaFile="$ARTIFACTS_DIR/test-results/junit.xml"

    elif grep -q '"test"' package.json 2>/dev/null; then
        echo "==> Running npm test..."
        npm test
        echo ""
        echo "NOTE: For coverage reports, configure your test runner to output to artifacts/"

    else
        echo "==> No test runner found in package.json"
        echo "    Add vitest, jest, or mocha to enable testing"
        echo ""
        # Create a summary file indicating no tests
        echo "No tests configured" > "$ARTIFACTS_DIR/coverage/summary.txt"
    fi

elif [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
    # Python project

    if command -v pytest &> /dev/null || grep -q 'pytest' pyproject.toml 2>/dev/null; then
        echo "==> Running tests with pytest..."
        pytest \
            --cov=. \
            --cov-report=json:"$ARTIFACTS_DIR/coverage/coverage.json" \
            --cov-report=html:"$ARTIFACTS_DIR/coverage/html" \
            --cov-report=term \
            --junitxml="$ARTIFACTS_DIR/test-results/junit.xml" \
            -v

    elif [[ -f "setup.py" ]] || [[ -f "setup.cfg" ]]; then
        echo "==> Running python -m unittest..."
        python -m unittest discover -v
        echo ""
        echo "NOTE: For coverage reports, install pytest and pytest-cov"

    else
        echo "==> No test runner found"
        echo "    Install pytest: pip install pytest pytest-cov"
        echo ""
        # Create a summary file indicating no tests
        echo "No tests configured" > "$ARTIFACTS_DIR/coverage/summary.txt"
    fi

else
    echo "==> No test configuration found"
    echo ""
    echo "This is a template repository. To add tests:"
    echo ""
    echo "  For Node.js projects:"
    echo "    npm install --save-dev vitest @vitest/coverage-v8"
    echo ""
    echo "  For Python projects:"
    echo "    pip install pytest pytest-cov"
    echo ""
    # Create a summary file indicating no tests
    echo "No tests configured - template repository" > "$ARTIFACTS_DIR/coverage/summary.txt"
fi

# Generate a simple coverage summary if not already created
if [[ ! -f "$ARTIFACTS_DIR/coverage/summary.txt" ]]; then
    echo "Coverage report generated at: $ARTIFACTS_DIR/coverage/" > "$ARTIFACTS_DIR/coverage/summary.txt"
    date >> "$ARTIFACTS_DIR/coverage/summary.txt"
fi

echo ""
echo "==> Tests complete!"
echo "    Coverage reports: $ARTIFACTS_DIR/coverage/"
echo "    Test results: $ARTIFACTS_DIR/test-results/"
