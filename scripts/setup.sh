#!/bin/bash

# Setup development environment for Love2D project
# Usage: ./scripts/setup.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔧 Setting up Love2D development environment..."
echo "============================================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo "Detected OS: $OS"

# 1. Check/Install Love2D
echo -n "Checking Love2D... "
if ! command -v love &> /dev/null; then
    echo "not found"
    echo "Installing Love2D..."
    
    case $OS in
        macos)
            if command -v brew &> /dev/null; then
                brew install love
            else
                echo "❌ Homebrew not found. Please install from https://brew.sh"
                echo "Then run: brew install love"
            fi
            ;;
        linux)
            echo "Please install Love2D using your package manager:"
            echo "  Ubuntu/Debian: sudo apt install love"
            echo "  Arch: sudo pacman -S love"
            echo "  Or download from https://love2d.org"
            ;;
        *)
            echo "Please download Love2D from https://love2d.org"
            ;;
    esac
else
    echo "✅ $(love --version)"
fi

# 2. Check/Install Lua
echo -n "Checking Lua... "
if ! command -v lua &> /dev/null; then
    echo "not found"
    echo "⚠️  Lua not found (optional but recommended)"
    case $OS in
        macos)
            echo "  Install with: brew install lua"
            ;;
        linux)
            echo "  Install with: sudo apt install lua5.3"
            ;;
    esac
else
    echo "✅ $(lua -v 2>&1 | head -n1)"
fi

# 3. Check/Install LuaRocks
echo -n "Checking LuaRocks... "
if ! command -v luarocks &> /dev/null; then
    echo "not found"
    echo "⚠️  LuaRocks not found (optional for testing tools)"
    case $OS in
        macos)
            echo "  Install with: brew install luarocks"
            ;;
        linux)
            echo "  Install with: sudo apt install luarocks"
            ;;
    esac
else
    echo "✅ $(luarocks --version | head -n1)"
fi

# 4. Create necessary directories
echo "Creating project directories..."
mkdir -p tests/components
mkdir -p tests/systems
mkdir -p tests/behaviors

# 5. Install Lua development tools if LuaRocks is available
if command -v luarocks &> /dev/null; then
    echo "Installing Lua development tools..."
    
    # Install luacheck for linting
    if ! command -v luacheck &> /dev/null; then
        echo "  Installing luacheck..."
        luarocks install luacheck --local || echo "  ⚠️  Failed to install luacheck"
    fi
    
    # Install busted for testing
    if ! lua -e "require('busted')" 2>/dev/null; then
        echo "  Installing busted..."
        luarocks install busted --local || echo "  ⚠️  Failed to install busted"
    fi
fi

# 6. Make all scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh

# 7. Create .luacheckrc if it doesn't exist
if [ ! -f ".luacheckrc" ]; then
    echo "Creating .luacheckrc..."
    cat > .luacheckrc << 'EOF'
-- Luacheck configuration for Love2D
std = "lua51+love"
ignore = {
    "212", -- Unused argument
    "213", -- Unused loop variable
}
globals = {
    "love",
}
exclude_files = {
    "tests/**/*.lua",
}
EOF
fi

echo "============================================="
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run the game: ./scripts/run.sh"
echo "2. Run tests: ./scripts/test.sh"
echo ""
echo "If any tools failed to install, you can install them manually."