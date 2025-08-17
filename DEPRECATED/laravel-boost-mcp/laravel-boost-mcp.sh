#!/usr/bin/env sh
set -e

curl -LsSf https://astral.sh/uv/install.sh | sh
/root/.local/bin/uv tool install mcp-proxy
/root/.local/bin/mcp-proxy --host	0.0.0.0 --port=3000 sail-php /var/www/html/artisan boost:mcp
