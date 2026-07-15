#!/usr/bin/env bash
[ "$SAIL_INSTALL_NOTION_CLI" != "true" ] && exit 0

# Official Notion CLI (ntn). The installer drops the binary into /usr/local/bin,
# which is already on PATH for every user, so no symlink is required.
curl -fsSL https://ntn.dev | bash
