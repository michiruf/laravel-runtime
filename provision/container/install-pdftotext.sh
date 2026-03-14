#!/usr/bin/env bash

if ! command -v pdftotext &> /dev/null; then
    apt-get update -qq && apt-get install -y -qq poppler-utils > /dev/null 2>&1
fi
