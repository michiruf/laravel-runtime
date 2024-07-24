#!/usr/bin/env bash

mysql --user=root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE}_test;
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}_test%\`.* TO '$MYSQL_USER'@'%';
EOSQL
