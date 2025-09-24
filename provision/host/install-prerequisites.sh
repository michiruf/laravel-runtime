#!/usr/bin/env sh

# Remove previous versions
sudo apt remove php8.3-*

# Install php
sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt update
sudo apt install php8.4 php8.4-cli php8.4-fpm php8.4-{bz2,curl,mbstring,intl,zip,dom,bcmath}

# Install composer
sudo apt install composer

# TODO Perform further the steps to prepare the wsl machine when they come up
