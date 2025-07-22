#!/bin/bash

# Run tests using Busted testing framework
# Usage: ./scripts/test.sh [busted-options]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running tests with Busted..."
echo "=============================="

# Track overall status
FAILED=0

# 1. Check if busted is installed
if ! command -v busted &> /dev/null; then
    echo "❌ Busted not installed"
    echo "Install with: luarocks install busted"
    exit 2
fi

# 2. Run linting first (if available)
if command -v luacheck &> /dev/null; then
    echo -n "Running linting... "
    if ./scripts/lint.sh > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "  Run './scripts/lint.sh' to see linting errors"
        FAILED=1
    fi
fi

# 3. Run tests with busted
echo "Running unit and integration tests..."
echo ""

# Pass through any command line arguments to busted
# Use --no-coverage by default since coverage setup is optional
if busted --verbose "$@"; then
    TEST_STATUS=0
else
    TEST_STATUS=1
    FAILED=1
fi

echo ""
echo "=============================="

# Report results
if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed!"
    exit 1
fi