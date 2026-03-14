ARG PHP_VERSION=8.4
FROM sail-${PHP_VERSION}/app

ARG PHP_VERSION=8.4
ARG SAIL_INSTALL_CLAUDE_CODE=false
ARG SAIL_INSTALL_GEMINI_CLI=false
ARG SAIL_INSTALL_PAPLAY=false
ARG SAIL_INSTALL_PDFTOTEXT=false

# PHP config
COPY sail-php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-sail.ini

# PHP wrapper
COPY sail-php.sh /usr/bin/sail-php
RUN chmod +x /usr/bin/sail-php

# Copy all feature scripts and run them automatically
# Each script checks its own build arg and exits early if not enabled
# To add a new feature: just add a new script to features/
COPY features/ /tmp/features/
RUN chmod +x /tmp/features/*.sh && \
    for script in /tmp/features/*.sh; do "$script"; done && \
    rm -rf /tmp/features
