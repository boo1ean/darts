#!/bin/bash

# Silent game validation for AI agents
# Usage: ./scripts/validate-game.sh
# Returns: 0 if game starts successfully, non-zero if failed

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Configuration
TIMEOUT_SECONDS=5
LOG_FILE="$PROJECT_ROOT/.tmp/game_validation.log"
PID_FILE="$PROJECT_ROOT/.tmp/game_validation.pid"

# Cleanup function
cleanup() {
    # Kill Love2D process if it's still running
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null || true
            # Give it a moment to terminate gracefully
            sleep 0.5
            # Force kill if still running
            kill -9 "$PID" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
    
    # Clean up log file
    rm -f "$LOG_FILE"
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

# Start Love2D in background with output redirected
love . > "$LOG_FILE" 2>&1 &
LOVE_PID=$!
echo "$LOVE_PID" > "$PID_FILE"

# Wait for game to initialize
echo -n "🔍 Validating game startup"
for i in $(seq 1 $TIMEOUT_SECONDS); do
    echo -n "."
    sleep 1
    
    # Check if process is still running
    if ! kill -0 "$LOVE_PID" 2>/dev/null; then
        echo ""
        echo "❌ Game crashed during startup"
        if [ -f "$LOG_FILE" ]; then
            echo "Last few lines of output:"
            tail -5 "$LOG_FILE" 2>/dev/null || echo "(no output captured)"
        fi
        exit 1
    fi
    
    # Check for common error patterns in output
    if [ -f "$LOG_FILE" ]; then
        if grep -i "error\|failed\|exception\|nil.*attempt" "$LOG_FILE" >/dev/null 2>&1; then
            echo ""
            echo "❌ Game startup errors detected"
            echo "Error details:"
            grep -i "error\|failed\|exception\|nil.*attempt" "$LOG_FILE" | head -3
            exit 1
        fi
    fi
done

# If we get here, game started successfully
echo ""
echo "✅ Game validation passed"

# Final check: game is still running
if kill -0 "$LOVE_PID" 2>/dev/null; then
    echo "✅ Game process stable after $TIMEOUT_SECONDS seconds"
    exit 0
else
    echo "❌ Game process terminated unexpectedly"
    exit 1
fi