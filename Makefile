# Makefile for project development
#
# Usage:
#   make help      - Show available targets
#   make bootstrap - Set up development environment
#   make ci        - Run full CI pipeline (same as GitHub Actions)
#
# All targets call scripts in the scripts/ directory.
# Language-specific logic lives in scripts, not here.

.PHONY: all bootstrap fmt fmt-check lint test build ci clean help

# Default target
all: ci

# Set up local development environment
# Installs dependencies based on project type (Node.js or Python)
bootstrap:
	@./scripts/bootstrap.sh

# Apply code formatting
# Modifies files in place
fmt:
	@./scripts/fmt.sh

# Check code formatting without modifying files
# Used in CI to verify formatting
fmt-check:
	@./scripts/fmt.sh --check

# Run linter and type checker
# Reports errors but does not modify files
lint:
	@./scripts/lint.sh

# Run tests and generate coverage reports
# Outputs to artifacts/ directory
test:
	@./scripts/test.sh

# Build project artifacts
# Outputs to artifacts/dist/ directory
build:
	@./scripts/build.sh

# Run full CI pipeline
# Equivalent to what runs in GitHub Actions
# Order: fmt-check → lint → test → build
ci:
	@./scripts/ci.sh

# Remove generated artifacts
clean:
	@rm -rf artifacts/
	@echo "Cleaned artifacts directory"

# Show available targets and their descriptions
help:
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  make bootstrap    Set up local development environment"
	@echo "  make fmt          Apply code formatting"
	@echo "  make fmt-check    Verify code formatting (no changes)"
	@echo "  make lint         Run linter and type checker"
	@echo "  make test         Run tests with coverage"
	@echo "  make build        Build project artifacts"
	@echo "  make ci           Run full CI pipeline (fmt-check + lint + test + build)"
	@echo "  make clean        Remove generated artifacts"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "CI Pipeline:"
	@echo ""
	@echo "  The 'make ci' target runs the same checks as GitHub Actions."
	@echo "  Run it locally before pushing to catch issues early."
	@echo ""
	@echo "  Pipeline order: fmt-check → lint → test → build"
	@echo ""
