#!/bin/bash
# Script d'initialisation de WordPress

# Si wp-config.php n'existe pas, procéder à l'installation initiale
if [ ! -f /var/www/html/wp-config.php ]; then
    # Télécharger et extraire WordPress dans /var/www/html
    curl -sSL https://wordpress.org/latest.tar.gz | tar -xz -C /var/www/html --strip-components=1

    # Copier le fichier de configuration exemple
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    # Remplacer les paramètres de base de données dans wp-config.php
    # (les variables DB_NAME, DB_USER, DB_PASSWORD, DB_HOST doivent être définies dans l'environnement)
    sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${DB_USER}/"     /var/www/html/wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/${DB_HOST}/"         /var/www/html/wp-config.php

    # (Optionnel) Définir les droits du propriétaire des fichiers sur www-data
    chown -R www-data:www-data /var/www/html
fi

# Démarrer PHP-FPM en mode premier plan (noyau). Le container restera actif.
exec php-fpm8.2 -F