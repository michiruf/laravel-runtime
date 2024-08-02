#!/usr/bin/env sh


# Install php
sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt update
sudo apt install php8.3 php8.3-cli php8.3-fpm php8.3-{bz2,curl,mbstring,intl,zip,dom,bcmath}

# Install composer
sudo apt install composer

# TODO Perform further the steps to prepare the wsl machine when they come up
