#!/bin/bash

# Format Lua files using StyLua
# Usage: ./scripts/format.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🎨 Formatting Lua files with StyLua..."
echo "====================================="

# Check if stylua is installed
if ! command -v stylua &> /dev/null; then
    echo "❌ StyLua not installed"
    echo "Install with: brew install stylua"
    exit 2
fi

# Format all Lua files
stylua .

echo "✅ Code formatting complete!"
echo "💡 Run ./scripts/lint.sh to check results"