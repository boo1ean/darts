#!/bin/bash

# Watch for file changes and auto-reload the Love2D game
# Usage: ./scripts/watch.sh

set -e

echo "👀 Starting Love2D Darts Game in watch mode..."

# Check if Love2D is installed
if ! command -v love &> /dev/null; then
    echo "❌ Error: Love2D is not installed"
    echo "Please install Love2D:"
    echo "  macOS: brew install love"
    echo "  Ubuntu: sudo apt install love"
    echo "  Windows: Download from https://love2d.org"
    exit 2
fi

# Check if fswatch is installed (macOS) or inotify-tools (Linux)
if command -v fswatch &> /dev/null; then
    WATCH_CMD="fswatch"
elif command -v inotifywait &> /dev/null; then
    WATCH_CMD="inotifywait"
else
    echo "❌ Error: No file watcher found"
    echo "Please install a file watcher:"
    echo "  macOS: brew install fswatch"
    echo "  Ubuntu: sudo apt install inotify-tools"
    exit 2
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to start the game
start_game() {
    if [ -n "$GAME_PID" ]; then
        echo "🔄 Reloading game..."
        kill $GAME_PID 2>/dev/null || true
        wait $GAME_PID 2>/dev/null || true
    else
        echo "🚀 Starting game..."
    fi
    
    cd "$PROJECT_ROOT"
    love . &
    GAME_PID=$!
    echo "✅ Game started with PID: $GAME_PID"
}

# Function to handle cleanup
cleanup() {
    echo -e "\n🛑 Stopping watch mode..."
    if [ -n "$GAME_PID" ]; then
        kill $GAME_PID 2>/dev/null || true
    fi
    exit 0
}

# Set up trap for cleanup
trap cleanup SIGINT SIGTERM

# Initial start
GAME_PID=""
start_game

# Watch for changes
echo "👀 Watching for file changes..."
echo "   Press Ctrl+C to stop"

if [ "$WATCH_CMD" = "fswatch" ]; then
    # macOS with fswatch
    fswatch -o -r \
        --exclude "\.git" \
        --exclude "\.love" \
        --include "\.lua$" \
        --include "\.png$" \
        "$PROJECT_ROOT" | while read change; do
        echo "📝 File changed, reloading..."
        start_game
    done
else
    # Linux with inotifywait
    while true; do
        inotifywait -r -e modify,create,delete,move \
            --exclude "(\.git|\.love)" \
            "$PROJECT_ROOT" \
            @/dev/null
        echo "📝 File changed, reloading..."
        start_game
    done
fi