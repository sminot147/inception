#!/bin/bash
# Script d'initialisation de WordPress



# ---------------------------------tester les varaiables d'environnements

# Si wp-config.php n'existe pas, procéder à l'installation initiale
if [ ! -f /var/www/html/myinit.txt ]; then
    echo "Initializing Wordpress database :"

    # Copier le fichier de configuration exemple
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

    # Remplacer les paramètres de base de données dans wp-config.php
    sed -i "s/database_name_here/${DB_NAME}/" /var/www/wordpress/wp-config.php
    sed -i "s/username_here/${DB_USER}/"     /var/www/wordpress/wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" /var/www/wordpress/wp-config.php
    sed -i "s/localhost/${DB_HOST}/"         /var/www/wordpress/wp-config.php

    # (Optionnel) Définir les droits du propriétaire des fichiers sur www-data
    chown -R www-data:www-data /var/www/wordpress
    echo "Wordpress database is initialize"

    touch /var/www/html/myinit.txt
else
  echo "Wordpress database is already initialize"
fi

# Démarrer PHP-FPM en mode premier plan (noyau). Le container restera actif.
exec php-fpm8.2 -F
