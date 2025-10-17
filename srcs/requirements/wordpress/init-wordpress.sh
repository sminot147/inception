#!/bin/bash
# Script d'initialisation de WordPress

i=0
until netcat -z "$MARIADB_HOST" 3306; do
    if [ $i == 10 ]; then
        echo "MariaDB no respsonse -- Exit"
        exit 1
    fi
    echo "Waiting for MariaDB..."
    sleep 2
    let i++
done

# ---------------------------------tester les varaiables d'environnements

# Si wp-config.php n'existe pas, procéder à l'installation initiale
if [ ! -f /var/www/wordpress/myinit.txt ]; then
    echo "Initializing Wordpress database :"

    wp core download --path=/var/www/wordpress --allow-root

    wp config create --allow-root \
        --dbname=$MARIADB_DATABASE \
        --dbuser=$MARIADB_USER \
        --dbpass=$MARIADB_USER_PWD \
        --dbhost=$MARIADB_HOST \
        --path=/var/www/wordpress

    wp core install --allow-root \
        --url=https://$DOMAIN_NAME \
        --title=Inception\
        --admin_user=$MARIADB_ROOT_USER \
        --admin_password=$MARIADB_ROOT_PWD \
        --path=/var/www/wordpress  \
        --admin_email=$WP_MAIL_ROOT

    wp user create --allow-root --role=author \
        $MARIADB_USER \
        $WP_MAIL_USER \
        --user_pass=$MARIADB_PASSWD \
        --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress

    touch /var/www/wordpress/myinit.txt
    echo "Wordpress database is initialize"
else
  echo "Wordpress database is already initialize"
fi

# Démarrer PHP-FPM en mode premier plan (noyau). Le container restera actif.
exec php-fpm8.2 -F
