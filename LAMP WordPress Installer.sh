#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update and upgrade the system
apt update && apt upgrade -y

# Install necessary dependencies
apt install -y wget curl software-properties-common gnupg2 debconf-utils

# Install Apache
apt install apache2 -y

# Install MySQL
apt install mysql-server -y

# Secure MySQL installation
mysql_secure_installation

# Install PHP 8 and necessary modules
add-apt-repository ppa:ondrej/php -y
apt update
apt install php8.0 php8.0-mysql libapache2-mod-php8.0 php8.0-cli php8.0-cgi php8.0-gd php8.0-xml php8.0-mbstring php8.0-curl php8.0-zip php-json -y

# Configure php.ini settings for WordPress
PHPINI=$(php --ini | grep "Loaded Configuration File" | awk '{print $4}')

sed -i "s/max_execution_time = .*/max_execution_time = 180/" $PHPINI
sed -i "s/memory_limit = .*/memory_limit = 128M/" $PHPINI
sed -i "s/post_max_size = .*/post_max_size = 64M/" $PHPINI
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/" $PHPINI
sed -i "s/max_input_time = .*/max_input_time = 60/" $PHPINI
sed -i "s/max_input_vars = .*/max_input_vars = 3000/" $PHPINI

# Restart Apache to apply changes
systemctl restart apache2

# Set up MySQL database and user for WordPress
echo "Enter the MySQL root password:"
read -s rootpasswd

echo "Enter the WordPress database name:"
read wpdbname

echo "Enter the WordPress MySQL user name:"
read wpdbuser

echo "Enter the WordPress MySQL user password:"
read -s wpdbpass

mysql -u root -p${rootpasswd} -e "CREATE DATABASE ${wpdbname};"
mysql -u root -p${rootpasswd} -e "CREATE USER '${wpdbuser}'@'localhost' IDENTIFIED BY '${wpdbpass}';"
mysql -u root -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${wpdbname}.* TO '${wpdbuser}'@'localhost';"
mysql -u root -p${rootpasswd} -e "FLUSH PRIVILEGES;"

# Download the latest version of WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz

# Move WordPress files to the Apache server directory
mv wordpress /var/www/html/

# Set the correct permissions
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Prompt for ServerAdmin email address
echo "Enter the ServerAdmin email address:"
read serveradminemail

# Create Apache configuration file for WordPress
tee /etc/apache2/sites-available/wordpress.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin $serveradminemail
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Enable the WordPress site and mod_rewrite
a2ensite wordpress
a2enmod rewrite

# Disable the default site
a2dissite 000-default

# Restart Apache to apply changes
systemctl restart apache2

# Preconfigure PHPMyAdmin
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $rootpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $rootpasswd" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# Install PHPMyAdmin
apt install phpmyadmin -y

# Enable PHPMyAdmin configuration in Apache
tee /etc/apache2/conf-available/phpmyadmin.conf > /dev/null <<EOL
Include /etc/phpmyadmin/apache.conf
EOL

a2enconf phpmyadmin
systemctl reload apache2

# Provide the real IP address or hostname
REAL_IP=$(curl -s http://checkip.amazonaws.com)
HOSTNAME=$(hostname -I | awk '{print $1}')

echo "Installation complete."
echo "Access your WordPress site at: http://$REAL_IP or http://$HOSTNAME"
echo "Access PHPMyAdmin at: http://$REAL_IP/phpmyadmin or http://$HOSTNAME/phpmyadmin"

# Clean up
rm /tmp/latest.tar.gz
