# Laravel Runtime

This is a laravel runtime for WSL using laravel-sail with a project-independent configuration directory.


## Prerequisites / Conditions

* A running WSL machine with bash
* Docker Desktop is installed and started
* Your shell must have admin privileges to update the Windows host file


## Runtime Installation Steps

1. Clone this repository anywhere to your WSL machine, except the `/mnt` directory.
2. Execute `install.sh` to add sourcing of this repositories `.bashrc` file to your own `~/.bashrc`.
3. Validate that the command worked inspecting your `~/.bashrc`.
4. (optional) Install php and composer dependencies on the WSL machine. This can be done with 
   `install-prerequisites.sh`, although this script might not be sufficient for all needs.
5. Start the docker-compose service in your runtime for automatic container discovery.
   This should in general needed to be done only once.
   ```shell
   cd my-runtime-path
   docker compose up -d
   ```


## Site Installation Steps

For each site you want to perform these steps to have the runtime set up properly.

1. In the WSL machine, navigate to the directory of your project.
2. Perform `composer install` to fetch laravel-sail in your project.
   > Since this is a standard dependency we want to use sail from the project rather than supplying one via the runtime.
3. Navigate to you runtime installation to the `sites` directory.
4. Copy on the example directories to a new name that matches your project directory name.
   For example:
   ```shell
   cp -R example-8.3 my-new-project
   ```
5. Open the docker-compose file in `my-new-project/docker-compose.yml` and replace all occurrences of *example*
   with *my-new-project*.
   This should replace:
   * The sail build context
   * The `VIRTUAL_HOST` environment variable value
   * The application volume mapping
6. Done. Navigate to your project directory and perform `sail up -d` to test if the project can start.


## Automatic Windows Host File Update

To automatically update the windows hosts file, perform following steps.

1. Navigate to `C:\Windows\System32\drivers\etc`.
2. Copy the `hosts` file to `hosts_template`.
3. Edit the `hosts_template` file and append
   ```
   ############################################
   # Automatic docker hosts generated with
   # github.com/michiruf/LaravelRuntime
   ############################################
   # update-hosts-file start
   
   # update-hosts-file end
   ############################################
   ```
4. Done. The hosts file will get updated between `# update-hosts-file start` and `# update-hosts-file end` whenever a
   sail command is executed.


## Site Installation in PHPStorm

1. Open the settings in PHPStorm
2. Navigate to the main configuration for **PHP**
3. In this window, find the setting for the CLI Interpreter
4. Click on dot-menu to open the CLI Interpreter configuration dialog
5. Click on the plus icon to add a new docker-compose interpreter
6. Choose docker-compose
7. Add a new server and select **WSL** from the radio select
8. For the configuration file, navigate to your runtime installation path and find the `docker-compose.yml` in the
   sites folder for the project you are currently configuring
9. Select the service *laravel-test* and hit OK
10. (recommended) Set the lifecycle to *Connect to existing container*
11. Done. Tests should now be runnable in PHPStorm.
12. *Optional*: use sail-php as php executable, to have it being run as sail user instead of root


## Related Information

* Configuring Windows Defender exclusion rules: https://github.com/microsoft/WSL/issues/8995#issuecomment-1380187901
  > [!WARNING]  
  > Might make your system vulnerable. Perform on your own risk!
