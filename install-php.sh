#!/usr/bin/env bash

# Remove previous versions
sudo apt remove php8.3-*
sudo apt remove php8.4-*
sudo apt remove composer

# Install php
sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt update
sudo apt install php8.5 php8.5-cli php8.5-fpm php8.5-{bz2,curl,mbstring,intl,zip,dom,bcmath}

# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
