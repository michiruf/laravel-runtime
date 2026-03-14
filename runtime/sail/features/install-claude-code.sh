#!/usr/bin/env bash
[ "$SAIL_INSTALL_CLAUDE_CODE" != "true" ] && exit 0

SAIL_HOME="/home/sail"
CLAUDE_BIN="$SAIL_HOME/.local/bin"

HOME="$SAIL_HOME" gosu sail bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

# Symlink to a directory already on PATH
ln -sf "$CLAUDE_BIN/claude" /usr/local/bin/claude

# Make .claude directory accessible
chmod -R a+rw "$SAIL_HOME/.claude" 2>/dev/null || true
