#!/usr/bin/env bash

if ! command -v gosu &> /dev/null; then
	apt-get update
	apt-get install -y gosu
fi

exec gosu sail "php" "$@"
