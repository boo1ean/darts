#!/bin/bash

# Comprehensive test suite for Love2D project
# Usage: ./scripts/test.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running Love2D Project Tests..."
echo "================================"

# Track overall status
FAILED=0

# 1. Check Love2D installation
echo -n "Checking Love2D installation... "
if command -v love &> /dev/null; then
    echo "✅"
else
    echo "❌"
    echo "  Love2D not found. Install with: brew install love"
    FAILED=1
fi

# 2. Run static analysis if available
if command -v luacheck &> /dev/null; then
    echo -n "Running static analysis... "
    if luacheck . --exclude-files "tests/*" > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "  Run 'luacheck .' to see errors"
        FAILED=1
    fi
else
    echo "⚠️  Luacheck not installed (optional)"
    echo "  Install with: luarocks install luacheck"
fi

# 3. Run unit tests if available
if [ -f "tests/test_runner.lua" ]; then
    echo -n "Running unit tests... "
    if lua tests/test_runner.lua > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "  Run 'lua tests/test_runner.lua' to see errors"
        FAILED=1
    fi
else
    echo "⚠️  No test runner found"
    echo "  Create tests/test_runner.lua to enable testing"
fi

# 4. Test game startup
if command -v love &> /dev/null; then
    echo -n "Testing game startup... "
    # Use timeout to prevent hanging
    if timeout 3 love . --test 2>/dev/null || [ $? -eq 124 ]; then
        echo "✅"
    else
        echo "❌"
        echo "  Game failed to start"
        FAILED=1
    fi
fi

# 5. Check for common issues
echo -n "Checking for common issues... "
ISSUES=0

# Check for syntax errors
if find . -name "*.lua" -not -path "./tests/*" -exec lua -c {} \; 2>&1 | grep -q "syntax error"; then
    ISSUES=1
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅"
else
    echo "❌"
    echo "  Found syntax errors in Lua files"
    FAILED=1
fi

echo "================================"

# Report results
if [ $FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi