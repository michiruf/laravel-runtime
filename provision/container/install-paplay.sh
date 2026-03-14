#!/usr/bin/env bash

if ! command -v paplay &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq pulseaudio-utils > /dev/null 2>&1
fi
