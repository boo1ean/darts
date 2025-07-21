#!/bin/bash

# Run the Love2D game
# Usage: ./scripts/run.sh

set -e

echo "🎯 Starting Love2D Darts Game..."

# Check if Love2D is installed
if ! command -v love &> /dev/null; then
    echo "❌ Error: Love2D is not installed"
    echo "Please install Love2D:"
    echo "  macOS: brew install love"
    echo "  Ubuntu: sudo apt install love"
    echo "  Windows: Download from https://love2d.org"
    exit 2
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Run the game
cd "$PROJECT_ROOT"
love .