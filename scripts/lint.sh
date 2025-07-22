#!/bin/bash

# Run static code analysis
# Usage: ./scripts/lint.sh [--fix]
#   --fix  Auto-fix formatting issues with stylua

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Parse arguments
FIX_MODE=0
if [[ "$1" == "--fix" ]]; then
    FIX_MODE=1
fi

echo "🔍 Running code analysis..."
echo "========================="

FAILED=0

# 1. Check if stylua is installed
if ! command -v stylua &> /dev/null; then
    echo "❌ stylua not installed"
    echo "Install with: cargo install stylua"
    exit 2
fi

# 2. Check if luacheck is installed
if ! command -v luacheck &> /dev/null; then
    echo "❌ luacheck not installed"
    echo "Install with: luarocks install luacheck"
    exit 2
fi

# 3. Run stylua formatting check/fix
if [[ $FIX_MODE -eq 1 ]]; then
    echo "Running stylua --fix..."
    if stylua .; then
        echo "✅ Code formatted with stylua"
    else
        echo "❌ stylua formatting failed"
        FAILED=1
    fi
else
    echo "Checking stylua formatting..."
    if stylua --check .; then
        echo "✅ Code formatting is consistent"
    else
        echo "❌ Code formatting issues found. Run with --fix to auto-format"
        FAILED=1
    fi
fi

# 4. Run luacheck
echo "Running luacheck..."
if luacheck . --codes; then
    echo "✅ No issues found"
else
    FAILED=1
fi

# 5. Check for common patterns
echo ""
echo "Checking for common issues..."

# Check for undefined globals using luacheck
echo -n "  Checking for undefined globals... "
GLOBALS=$(luacheck . --codes --only 113 2>/dev/null | grep "113" | wc -l)
if [ "$GLOBALS" -eq 0 ]; then
    echo "✅"
else
    echo "⚠️  Found $GLOBALS undefined global accesses"
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