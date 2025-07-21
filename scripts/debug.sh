#!/bin/bash

# Run game in debug mode with additional logging
# Usage: ./scripts/debug.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🐛 Starting Love2D in debug mode..."

# Check if Love2D is installed
if ! command -v love &> /dev/null; then
    echo "❌ Error: Love2D is not installed"
    exit 2
fi

# Create a temporary conf.lua with debug settings
cat > conf_debug.lua << 'EOF'
-- Debug configuration
function love.conf(t)
    t.console = true  -- Enable console on Windows
    t.window.title = "Love2D Darts [DEBUG]"
end

-- Load original conf if exists
if love.filesystem.getInfo("config.lua") then
    require("config")
end
EOF

# Run with debug configuration
LOVE_DEBUG=1 love . --console

# Clean up
rm -f conf_debug.lua