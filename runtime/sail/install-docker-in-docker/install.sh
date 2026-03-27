#!/usr/bin/env bash
[ "$SAIL_INSTALL_DOCKER_IN_DOCKER" != "true" ] && exit 0

# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
apt-get update \
	&& apt-get install -y ca-certificates curl gnupg \
	&& install -m 0755 -d /etc/apt/keyrings \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
	&& chmod a+r /etc/apt/keyrings/docker.asc \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
	&& apt-get update \
	&& apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Allow sail user to access the docker socket
usermod -aG docker sail

# Start dockerd via supervisord (vfs slow, but works everywhere)
cat >> /etc/supervisor/conf.d/supervisord.conf <<'SUPERVISOR'

[program:dockerd]
command=/usr/bin/dockerd --storage-driver=vfs
autostart=true
autorestart=true
stderr_logfile=/var/log/dockerd.err.log
stdout_logfile=/var/log/dockerd.out.log
SUPERVISOR
