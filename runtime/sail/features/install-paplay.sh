#!/usr/bin/env bash
[ "$SAIL_INSTALL_PAPLAY" != "true" ] && exit 0

apt-get update -qq && apt-get install -y -qq pulseaudio-utils > /dev/null 2>&1
