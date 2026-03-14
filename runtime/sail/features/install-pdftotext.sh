#!/usr/bin/env bash
[ "$SAIL_INSTALL_PDFTOTEXT" != "true" ] && exit 0

apt-get update -qq && apt-get install -y -qq poppler-utils > /dev/null 2>&1
