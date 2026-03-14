#!/usr/bin/env bash
[ "$SERVICE_LOCAL_PROXY" != "true" ] && exit 0

cd "$(dirname "$0")" && docker-compose "$@"
