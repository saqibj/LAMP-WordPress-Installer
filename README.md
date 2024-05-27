# WordPress & LAMP Installation Script

This script installs a LAMP stack (Linux, Apache, MySQL, PHP) on an Ubuntu server, deploys the latest version of WordPress, and sets up PHPMyAdmin for database management. The script ensures all necessary dependencies are installed and configures PHP settings suitable for a WordPress installation. Upon completion, it provides the IP address and hostname where the WordPress site and PHPMyAdmin can be accessed.

## Prerequisites

- An Ubuntu server
- Root access to the server

## Usage

1. Save the script to a file, for example, `install_wordpress.sh`.
2. Make the script executable by running:
    ```bash
    chmod +x install_wordpress.sh
    ```
3. Execute the script with:
    ```bash
    sudo ./install_wordpress.sh
    ```

## Script Prompts

The script will prompt you for the following inputs:

- MySQL root password
- WordPress database name
- WordPress MySQL username
- WordPress MySQL user password
- ServerAdmin email address

## What the Script Does

1. Updates and upgrades the system packages.
2. Installs Apache web server.
3. Installs MySQL database server and secures the installation.
4. Installs PHP 8 and necessary PHP modules.
5. Configures `php.ini` settings for WordPress:
    - `max_execution_time = 180`
    - `memory_limit = 128M`
    - `post_max_size = 64M`
    - `upload_max_filesize = 64M`
    - `max_input_time = 60`
    - `max_input_vars = 3000`
6. Sets up a MySQL database and user for WordPress.
7. Downloads and deploys the latest version of WordPress.
8. Sets the correct permissions for WordPress files.
9. Prompts for and sets the ServerAdmin email address in Apache configuration.
10. Configures Apache to serve the WordPress site.
11. Installs and configures PHPMyAdmin for database management.
12. Provides the real IP address and hostname for accessing the WordPress site and PHPMyAdmin.

## Accessing the Services

Upon completion, the script will output the IP address and hostname where you can access the services:

- **WordPress site:** `http://<IP_ADDRESS>` or `http://<HOSTNAME>`
- **PHPMyAdmin:** `http://<IP_ADDRESS>/phpmyadmin` or `http://<HOSTNAME>/phpmyadmin`

## Clean Up

The script will clean up temporary files used during the installation process.

## Notes

- Ensure that the necessary ports (80 for HTTP) are open on your server's firewall.
- The script must be run as root to perform all the required tasks.
