#!/usr/bin/env bash
[ "$SERVICE_LLM_PROXY" != "true" ] && exit 0

cd "$(dirname "$0")" && docker-compose "$@"
