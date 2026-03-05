#!/usr/bin/env bash

SAIL_HOME="/home/sail"
CLAUDE_BIN="$SAIL_HOME/.local/bin"

# Load correct path initially
export PATH="$CLAUDE_BIN:$PATH"

# Ensure sail user owns its .claude directory (may be a mounted volume)
#chown -R sail:sail "$SAIL_HOME/.claude" 2>/dev/null || true

# Ensure sail user owns the download directory only
#mkdir -p "$SAIL_HOME/.claude/downloads"
#chown -R sail:sail "$SAIL_HOME/.claude/downloads"

# Make mounted .claude directory accessible without changing ownership
chmod -R a+rw "$SAIL_HOME/.claude" 2>/dev/null || true

# Install if no claude exists
if ! command -v claude &> /dev/null; then
    HOME="$SAIL_HOME" gosu sail bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

    # Symlink to a directory already on PATH
    ln -sf "$CLAUDE_BIN/claude" /usr/local/bin/claude
fi
