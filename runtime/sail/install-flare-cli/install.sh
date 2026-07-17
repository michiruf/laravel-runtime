#!/usr/bin/env bash
[ "$SAIL_INSTALL_FLARE_CLI" != "true" ] && exit 0

# Flare CLI (https://flareapp.io/docs/flare/general/using-the-cli), installed
# globally via Composer as the sail user.
HOME=/home/sail COMPOSER_HOME=/home/sail/.composer gosu sail composer global require spatie/flare-cli

# Symlink to a directory already on PATH
ln -sf /home/sail/.composer/vendor/bin/flare /usr/local/bin/flare

# At runtime, fix ownership of ~/.flare: when the host directory doesn't exist,
# Docker auto-creates it root-owned while mounting, so `flare login` can't write
# its config.json. The directory is empty in that case, so chowning it to sail
# is safe.
cat > /usr/local/bin/flare-permissions.sh << 'BASH'
#!/usr/bin/env bash
FLARE_DIR="/home/sail/.flare"
if [ -d "$FLARE_DIR" ] && [ "$(stat -c '%u' "$FLARE_DIR")" = "0" ]; then
    chown -R sail:sail "$FLARE_DIR"
fi
BASH
chmod +x /usr/local/bin/flare-permissions.sh
# Append to the config supervisord is actually started with (`start-container`
# runs `supervisord -c /etc/supervisor/conf.d/supervisord.conf`, which has no
# [include] section, so separate conf.d drop-in files are never loaded).
cat >> /etc/supervisor/conf.d/supervisord.conf << 'CONF'

[program:flare-permissions]
command=/usr/local/bin/flare-permissions.sh
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
