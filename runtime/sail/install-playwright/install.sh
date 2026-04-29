#!/usr/bin/env bash
[ "$SAIL_INSTALL_PLAYWRIGHT" != "true" ] && exit 0

npm install -g playwright @playwright/test
playwright install-deps

# Persist the browser path for runtime so the sail user finds them
echo 'export PLAYWRIGHT_BROWSERS_PATH=/home/sail/.cache/ms-playwright' >> /home/sail/.bashrc

HOME=/home/sail PLAYWRIGHT_BROWSERS_PATH=/home/sail/.cache/ms-playwright gosu sail playwright install
