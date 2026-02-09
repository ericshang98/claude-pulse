#!/usr/bin/env bash
set -euo pipefail

SYMLINK="/usr/local/bin/claude-pulse"
CONFIG_DIR="$HOME/.claude-pulse"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PREFIX="com.claude-pulse"

echo "Uninstalling Claude Pulse..."

# Stop agents if claude-pulse is available
if command -v claude-pulse > /dev/null 2>&1; then
    claude-pulse stop 2>/dev/null || true
else
    # Manual unload
    for plist in "$LAUNCH_AGENTS_DIR"/${PLIST_PREFIX}.*.plist; do
        [[ -f "$plist" ]] || continue
        launchctl unload "$plist" 2>/dev/null || true
    done
fi

# Remove plists
rm -f "$LAUNCH_AGENTS_DIR"/${PLIST_PREFIX}.*.plist
echo "Removed launch agents"

# Remove config directory
if [[ -d "$CONFIG_DIR" ]]; then
    rm -rf "$CONFIG_DIR"
    echo "Removed $CONFIG_DIR"
fi

# Remove symlink
if [[ -L "$SYMLINK" || -f "$SYMLINK" ]]; then
    sudo rm -f "$SYMLINK"
    echo "Removed $SYMLINK"
fi

echo ""
echo "Uninstall complete."
echo ""
echo "Note: If you set a pmset wake schedule, remove it manually:"
echo "  sudo pmset repeat cancel"
