#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/claude-pulse"
TARGET="/usr/local/bin/claude-pulse"

echo "Installing Claude Pulse..."

# Ensure source exists and is executable
if [[ ! -f "$SOURCE" ]]; then
    echo "Error: claude-pulse not found in $SCRIPT_DIR"
    exit 1
fi
chmod +x "$SOURCE"

# Create symlink (may require sudo)
if [[ -L "$TARGET" || -f "$TARGET" ]]; then
    echo "Removing existing $TARGET..."
    sudo rm -f "$TARGET"
fi

sudo ln -s "$SOURCE" "$TARGET"
echo "Symlinked $TARGET -> $SOURCE"

# Verify
if command -v claude-pulse > /dev/null 2>&1; then
    echo "Success! 'claude-pulse' is now available in PATH."
    echo ""
    echo "Run 'claude-pulse setup' to configure."
else
    echo "Warning: claude-pulse is installed but not found in PATH."
    echo "Ensure /usr/local/bin is in your PATH."
fi
