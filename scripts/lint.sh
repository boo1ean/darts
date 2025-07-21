#!/bin/bash

# Run static code analysis
# Usage: ./scripts/lint.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 Running code analysis..."
echo "========================="

FAILED=0

# 1. Check if luacheck is installed
if ! command -v luacheck &> /dev/null; then
    echo "❌ luacheck not installed"
    echo "Install with: luarocks install luacheck"
    exit 2
fi

# 2. Run luacheck
echo "Running luacheck..."
if luacheck . --codes; then
    echo "✅ No issues found"
else
    FAILED=1
fi

# 3. Check for common patterns
echo ""
echo "Checking for common issues..."

# Check for global variables (excluding love)
echo -n "  Checking for undefined globals... "
GLOBALS=$(grep -r "^[^local].*=" *.lua 2>/dev/null | grep -v "love\." | grep -v "function" | wc -l)
if [ "$GLOBALS" -eq 0 ]; then
    echo "✅"
else
    echo "⚠️  Found $GLOBALS potential global variables"
fi

# Check for print statements (should use proper logging)
echo -n "  Checking for debug prints... "
PRINTS=$(grep -r "print(" *.lua 2>/dev/null | wc -l)
if [ "$PRINTS" -eq 0 ]; then
    echo "✅"
else
    echo "⚠️  Found $PRINTS print statements"
fi

echo "========================="

if [ $FAILED -eq 0 ]; then
    echo "✅ Code analysis passed!"
    exit 0
else
    echo "❌ Code analysis found issues"
    exit 1
fi