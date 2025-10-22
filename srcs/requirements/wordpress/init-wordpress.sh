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

set -e

# Si wp-config.php n'existe pas, procéder à l'installation initiale
if [ ! -f /var/www/wordpress/myinit.txt ]; then
    echo "Initializing Wordpress database :"


    : ${MARIADB_DATABASE:?"MARIADB_DATABASE is not set"}
    : ${MARIADB_USER:?"MARIADB_USER is not set"}
    : ${MARIADB_USER_PWD:?"MARIADB_USER_PWD is not set"}
    : ${MARIADB_HOST:?"MARIADB_HOST is not set"}
    : ${DOMAIN_NAME:?"DOMAIN_NAME is not set"}
    : ${MARIADB_ROOT_USER:?"MARIADB_ROOT_USER is not set"}
    : ${MARIADB_ROOT_PWD:?"MARIADB_ROOT_PWD is not set"}
    : ${WP_MAIL_ROOT:?"WP_MAIL_ROOT is not set"}
    : ${WP_MAIL_USER:?"WP_MAIL_USER is not set"}


    # --- MARIADB_DATABASE (database name)
    case "$MARIADB_DATABASE" in
    (*[!a-zA-Z0-9_]*|"") echo "MARIADB_DATABASE contains invalid characters (allowed: a-z, A-Z, 0-9, _)" >&2; exit 1 ;;
    esac

    # --- MARIADB_USER (username)
    case "$MARIADB_USER" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "MARIADB_USER contains invalid characters (allowed: a-z, A-Z, 0-9, _, ., @, -)" >&2; exit 1 ;;
    esac

    # --- MARIADB_USER_PWD (password)
    case "$MARIADB_USER_PWD" in
    (*[!a-zA-Z0-9!@#%^_+\-=:.,?]*|"") echo "MARIADB_USER_PWD contains invalid characters (avoid shell meta chars)" >&2; exit 1 ;;
    esac

    # --- MARIADB_HOST (hostname or IP)
    case "$MARIADB_HOST" in
    (*[!a-zA-Z0-9_.-]*|"") echo "MARIADB_HOST contains invalid characters (allowed: a-z, A-Z, 0-9, ., -, _)" >&2; exit 1 ;;
    esac

    # --- DOMAIN_NAME (domain name)
    case "$DOMAIN_NAME" in
    (*[!a-zA-Z0-9.-]*|"") echo "DOMAIN_NAME contains invalid characters (allowed: a-z, A-Z, 0-9, ., -)" >&2; exit 1 ;;
    (.*|*..*.) echo "DOMAIN_NAME seems invalid (check format)" >&2; exit 1 ;;
    esac

    # --- MARIADB_ROOT_USER (username)
    case "$MARIADB_ROOT_USER" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "MARIADB_ROOT_USER contains invalid characters (allowed: a-z, A-Z, 0-9, _, ., @, -)" >&2; exit 1 ;;
    esac

    # --- MARIADB_ROOT_PWD (password)
    case "$MARIADB_ROOT_PWD" in
    (*[!a-zA-Z0-9!@#%^_+\-=:.,?]*|"") echo "MARIADB_ROOT_PWD contains invalid characters (avoid shell meta chars)" >&2; exit 1 ;;
    esac

    # --- WP_MAIL_ROOT (email)
    case "$WP_MAIL_ROOT" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "WP_MAIL_ROOT contains invalid characters (allowed: a-z, A-Z, 0-9, _, ., @, -)" >&2; exit 1 ;;
    (*@*.*) ;; 
    (*) echo "WP_MAIL_ROOT seems invalid (must contain '@' and '.')" >&2; exit 1 ;;
    esac

    # --- WP_MAIL_USER (email)
    case "$WP_MAIL_USER" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "WP_MAIL_USER contains invalid characters (allowed: a-z, A-Z, 0-9, _, ., @, -)" >&2; exit 1 ;;
    (*@*.*) ;; 
    (*) echo "WP_MAIL_USER seems invalid (must contain '@' and '.')" >&2; exit 1 ;;
    esac



    wp core download --path=/var/www/wordpress --allow-root

    wp config create --allow-root --dbname=$MARIADB_DATABASE --dbuser=$MARIADB_USER --dbpass=$MARIADB_USER_PWD --dbhost=$MARIADB_HOST --path=/var/www/wordpress

    wp core install --allow-root --url=https://$DOMAIN_NAME --title=Inception --admin_user=$MARIADB_ROOT_USER --admin_password=$MARIADB_ROOT_PWD --path=/var/www/wordpress  --admin_email=$WP_MAIL_ROOT

    wp user create --allow-root --role=author $MARIADB_USER $WP_MAIL_USER --user_pass=$MARIADB_USER_PWD --path=/var/www/wordpress

    chown -R www-data:www-data /var/www/wordpress

    touch /var/www/wordpress/myinit.txt
    echo "Wordpress database is initialize"
else
  echo "Wordpress database is already initialize"
fi

# Démarrer PHP-FPM en mode premier plan (noyau). Le container restera actif.
exec php-fpm8.2 -F
