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

# 5. Install stylua for code formatting
echo -n "Checking StyLua... "
if ! command -v stylua &> /dev/null; then
    echo "not found"
    echo "Installing StyLua..."
    
    case $OS in
        macos)
            if command -v brew &> /dev/null; then
                brew install stylua
            elif command -v cargo &> /dev/null; then
                cargo install stylua
            else
                echo "❌ Neither Homebrew nor Cargo found."
                echo "Please install StyLua manually:"
                echo "  - With Homebrew: brew install stylua"
                echo "  - With Cargo: cargo install stylua"
                echo "  - Download from: https://github.com/JohnnyMorganz/StyLua/releases"
            fi
            ;;
        linux)
            if command -v cargo &> /dev/null; then
                cargo install stylua
            else
                echo "❌ Cargo not found."
                echo "Please install StyLua manually:"
                echo "  - With Cargo: cargo install stylua"
                echo "  - Download from: https://github.com/JohnnyMorganz/StyLua/releases"
            fi
            ;;
        *)
            echo "Please install StyLua manually:"
            echo "  - With Cargo: cargo install stylua"
            echo "  - Download from: https://github.com/JohnnyMorganz/StyLua/releases"
            ;;
    esac
else
    echo "✅ $(stylua --version)"
fi

# 6. Install Lua development tools if LuaRocks is available
if command -v luarocks &> /dev/null; then
    echo "Installing Lua development tools..."
    
    # Install luacheck for linting
    echo -n "  Checking luacheck... "
    if ! command -v luacheck &> /dev/null; then
        echo "installing..."
        if luarocks install luacheck --local; then
            echo "    ✅ luacheck installed"
            # Add local luarocks bin to PATH hint
            echo "    💡 You may need to add ~/.luarocks/bin to your PATH"
        else
            echo "    ❌ Failed to install luacheck"
            echo "    Try installing globally: sudo luarocks install luacheck"
        fi
    else
        echo "✅ $(luacheck --version | head -n1)"
    fi
    
    # Install busted for testing
    echo -n "  Checking busted... "
    if ! lua -e "require('busted')" 2>/dev/null; then
        echo "installing..."
        if luarocks install busted --local; then
            echo "    ✅ busted installed"
        else
            echo "    ❌ Failed to install busted"
            echo "    Try installing globally: sudo luarocks install busted"
        fi
    else
        echo "✅ busted available"
    fi
else
    echo "⚠️  LuaRocks not available - skipping luacheck and busted installation"
    echo "Install LuaRocks to get full development tools support"
fi

# 7. Make all scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh

# 8. Create .luacheckrc if it doesn't exist
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

# 9. Check PATH configuration for local luarocks
if command -v luarocks &> /dev/null; then
    LUAROCKS_BIN="$(luarocks path --lr-bin 2>/dev/null)"
    if [ -n "$LUAROCKS_BIN" ] && [[ ":$PATH:" != *":$LUAROCKS_BIN:"* ]]; then
        echo ""
        echo "⚠️  Local LuaRocks bin directory is not in your PATH"
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"\$PATH:$LUAROCKS_BIN\""
        echo ""
    fi
fi

# 10. Validate installation
echo "Validating installation..."
SETUP_FAILED=0

# Check Love2D
if ! command -v love &> /dev/null; then
    echo "❌ Love2D not available"
    SETUP_FAILED=1
fi

# Check stylua
if ! command -v stylua &> /dev/null; then
    echo "❌ stylua not available - lint.sh will fail"
    SETUP_FAILED=1
fi

# Check luacheck
if ! command -v luacheck &> /dev/null; then
    echo "❌ luacheck not available - lint.sh and test.sh will fail"
    SETUP_FAILED=1
fi

# Check busted
if ! lua -e "require('busted')" 2>/dev/null; then
    echo "❌ busted not available - test.sh will fail"
    SETUP_FAILED=1
fi

echo "============================================="
if [ $SETUP_FAILED -eq 0 ]; then
    echo "✅ Setup complete! All dependencies are available."
    echo ""
    echo "Next steps:"
    echo "1. Run comprehensive validation: ./scripts/validate-all.sh"
    echo "2. Run the game: ./scripts/run.sh"
    echo "3. Run tests: ./scripts/test.sh"
    echo "4. Format code: ./scripts/lint.sh --fix"
else
    echo "⚠️  Setup completed with some issues."
    echo "Some scripts may not work until missing dependencies are installed."
    echo ""
    echo "Next steps:"
    echo "1. Install missing dependencies manually"
    echo "2. If tools are installed but not found, check your PATH configuration"
    echo "3. Restart your shell or source your profile to pick up PATH changes"
fi
echo ""