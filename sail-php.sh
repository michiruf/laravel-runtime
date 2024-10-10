#!/usr/bin/env bash

# If we are already the sail user, just execute php
if [ "$(whoami)" = "sail" ]; then
  exec php "$@"
fi

# In case gosu is not available (which it is in sail), install it
if ! command -v gosu &> /dev/null; then
	apt-get update
	apt-get install -y gosu
fi

exec gosu sail "php" "$@"
