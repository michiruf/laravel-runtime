#!/usr/bin/env bash
[ "$SAIL_INSTALL_CLAUDE_CODE" != "true" ] && exit 0

SAIL_HOME="/home/sail"
SAIL_HOME_BIN="$SAIL_HOME/.local/bin"

HOME="$SAIL_HOME" gosu sail bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

# Symlink to a directory already on PATH
ln -sf "$SAIL_HOME_BIN/claude" /usr/local/bin/claude

# Also add ~/.local/bin to PATH for interactive sessions
echo "export PATH=\"$SAIL_HOME_BIN:\$PATH\"" >> "$SAIL_HOME/.bashrc"

# At runtime, add sail user to the group that owns ~/.claude (mounted from host)
cat > /usr/local/bin/claude-permissions.sh << 'BASH'
#!/usr/bin/env bash
CLAUDE_DIR="/home/sail/.claude"
if [ -d "$CLAUDE_DIR" ]; then
    CLAUDE_GID=$(stat -c '%g' "$CLAUDE_DIR")
    if ! id -nG sail | grep -qw "$(getent group "$CLAUDE_GID" | cut -d: -f1)" 2>/dev/null; then
        groupadd -g "$CLAUDE_GID" claudehost 2>/dev/null || true
        usermod -aG "$CLAUDE_GID" sail
    fi
fi
BASH
chmod +x /usr/local/bin/claude-permissions.sh
cat > /etc/supervisor/conf.d/claude-permissions.conf << 'CONF'
[program:claude-permissions]
command=/usr/local/bin/claude-permissions.sh
user=root
autorestart=false
startsecs=0
startretries=1
priority=1
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
CONF
