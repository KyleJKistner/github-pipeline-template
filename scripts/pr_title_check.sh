#!/usr/bin/env bash
set -euo pipefail

# Validate PR title follows Conventional Commits format
# Usage: pr_title_check.sh "feat(scope): description"
#
# Conventional Commits: https://www.conventionalcommits.org/

TITLE="${1:-}"

if [[ -z "$TITLE" ]]; then
    echo "ERROR: No PR title provided"
    echo ""
    echo "Usage: $0 \"<PR title>\""
    exit 1
fi

# Conventional Commits pattern
# Format: type(optional-scope): description
#
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Scope: optional, lowercase alphanumeric with hyphens
# Description: 1-72 characters, starts with lowercase (unless proper noun)
#
# Breaking changes use ! after type or scope: feat!, feat(api)!
#
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?\!?: .{1,72}$'

if [[ ! "$TITLE" =~ $PATTERN ]]; then
    echo "ERROR: PR title does not follow Conventional Commits format"
    echo ""
    echo "========================================"
    echo "  Expected Format"
    echo "========================================"
    echo ""
    echo "  <type>(<scope>): <description>"
    echo ""
    echo "  type (required):"
    echo "    feat     - New feature"
    echo "    fix      - Bug fix"
    echo "    docs     - Documentation only"
    echo "    style    - Formatting, no code change"
    echo "    refactor - Code restructuring"
    echo "    perf     - Performance improvement"
    echo "    test     - Adding/updating tests"
    echo "    build    - Build system changes"
    echo "    ci       - CI configuration"
    echo "    chore    - Maintenance tasks"
    echo "    revert   - Revert previous commit"
    echo ""
    echo "  scope (optional):"
    echo "    Lowercase with hyphens, e.g., (auth), (api), (user-service)"
    echo ""
    echo "  description:"
    echo "    1-72 characters, imperative mood"
    echo ""
    echo "  Breaking changes:"
    echo "    Add ! after type: feat!: or feat(api)!:"
    echo ""
    echo "========================================"
    echo "  Examples"
    echo "========================================"
    echo ""
    echo "  feat(auth): add OAuth2 login support"
    echo "  fix: resolve null pointer in user lookup"
    echo "  docs: update API reference"
    echo "  refactor(utils): simplify date formatting"
    echo "  feat!: remove deprecated v1 endpoints"
    echo ""
    echo "========================================"
    echo "  Your Title"
    echo "========================================"
    echo ""
    echo "  $TITLE"
    echo ""
    exit 1
fi

echo "PR title is valid: $TITLE"
