#!/usr/bin/env bash
[ "$SAIL_INSTALL_GEMINI_CLI" != "true" ] && exit 0

npm install -g @google/gemini-cli
