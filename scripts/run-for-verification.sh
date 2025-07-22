#!/bin/bash

# Start game silently for manual verification by AI agents
# Usage: ./scripts/run-for-verification.sh
# Returns: 0 if game starts successfully, exits with status if failed

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Configuration
LOG_FILE="$PROJECT_ROOT/.tmp/verification_game.log"
PID_FILE="$PROJECT_ROOT/.tmp/verification_game.pid"

# Cleanup function
cleanup() {
    # Remove PID file when script exits
    rm -f "$PID_FILE"
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Check if Love2D is installed
if ! command -v love &> /dev/null; then
    echo "❌ Love2D not installed"
    exit 2
fi

# Ensure .tmp directory exists
mkdir -p "$PROJECT_ROOT/.tmp"

# Check if game is already running for verification
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        echo "✅ Game already running for verification (PID: $PID)"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Start Love2D with output redirected to log file
love . > "$LOG_FILE" 2>&1 &
LOVE_PID=$!
echo "$LOVE_PID" > "$PID_FILE"

# Brief startup check
sleep 2

# Check if process started successfully
if ! kill -0 "$LOVE_PID" 2>/dev/null; then
    echo "❌ Game failed to start"
    if [ -f "$LOG_FILE" ]; then
        echo "Error details:"
        tail -10 "$LOG_FILE" 2>/dev/null || echo "(no output captured)"
    fi
    exit 1
fi

# Check for startup errors
if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
    if grep -q "^Error:" "$LOG_FILE"; then
        echo "❌ Game startup errors detected"
        echo "Error details:"
        grep -A 10 "^Error:" "$LOG_FILE" | head -15
        exit 1
    fi
fi

echo "✅ Game started for verification (PID: $LOVE_PID)"
echo "💡 Use './scripts/stop-verification.sh' to stop the game when done"