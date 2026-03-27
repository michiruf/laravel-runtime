ARG PHP_VERSION=8.4
FROM sail-${PHP_VERSION}/app

ARG PHP_VERSION=8.4
ARG SAIL_INSTALL_CLAUDE_CODE=false
ARG SAIL_INSTALL_DOCKER_IN_DOCKER=false
ARG DOCKER_SOCKET_GID=1001
ARG SAIL_INSTALL_GEMINI_CLI=false
ARG SAIL_INSTALL_GH_CLI=false
ARG SAIL_INSTALL_PAPLAY=false
ARG SAIL_INSTALL_PDFTOTEXT=false

# PHP config
COPY sail-php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-sail.ini

# PHP wrapper
COPY sail-php.sh /usr/bin/sail-php
RUN chmod +x /usr/bin/sail-php

# Copy and run feature install scripts
# Each script checks its own build arg and exits early if not enabled
# To add a new feature: create a subdirectory with an install.sh
COPY . /tmp/features/
RUN chmod +x /tmp/features/*/install.sh && \
    for script in /tmp/features/*/install.sh; do "$script"; done && \
    rm -rf /tmp/features
