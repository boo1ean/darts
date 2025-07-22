#!/bin/bash

# Stop game running for verification
# Usage: ./scripts/stop-verification.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$PROJECT_ROOT/.tmp/verification_game.pid"
LOG_FILE="$PROJECT_ROOT/.tmp/verification_game.log"

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "ℹ️  No verification game running"
    exit 0
fi

# Get PID and check if process exists
PID=$(cat "$PID_FILE" 2>/dev/null || echo "")
if [ -z "$PID" ]; then
    echo "ℹ️  No valid PID found"
    rm -f "$PID_FILE"
    exit 0
fi

# Check if process is actually running
if ! kill -0 "$PID" 2>/dev/null; then
    echo "ℹ️  Game process already stopped"
    rm -f "$PID_FILE"
    rm -f "$LOG_FILE"
    exit 0
fi

# Terminate the game process
echo "🛑 Stopping verification game (PID: $PID)"
kill "$PID" 2>/dev/null || true

# Give it a moment to terminate gracefully
sleep 1

# Force kill if still running
if kill -0 "$PID" 2>/dev/null; then
    echo "⚠️  Force killing game process"
    kill -9 "$PID" 2>/dev/null || true
fi

# Clean up files
rm -f "$PID_FILE"
rm -f "$LOG_FILE"

echo "✅ Verification game stopped"