#!/bin/bash

# Check the required environment variables
#test existance and not empty
: ${MARIADB_ROOT_PASSWORD:?"MARIADB_ROOT_PASSWORD is not set"}
: ${MARIADB_DATABASE:?"MARIADB_DATABASE is not set"}
: ${MARIADB_USER:?"MARIADB_USER is not set"}
: ${MARIADB_USER_PASSWORD:?"MARIADB_USER_PASSWORD is not set"}


#test for invalid characters
case "$MARIADB_ROOT_PASSWORD" in
  (*[!!-~]*|"") echo "MARIADB_ROOT_PASSWORD contains invalid characters" >&2; exit 1 ;;
esac

case "$MARIADB_USER_PASSWORD" in
  (*[!!-~]*|"") echo "MARIADB_USER_PASSWORD contains invalid characters" >&2; exit 1 ;;
esac

case "$MARIADB_USER" in
  (*[!a-zA-Z0-9_]*|"") echo "MARIADB_USER contains invalid characters" >&2; exit 1 ;;
esac

case "$MARIADB_DATABASE" in
  (*[!a-zA-Z0-9_]*|"") echo "MARIADB_DATABASE contains invalid characters" >&2; exit 1 ;;
esac


if [ ! -f "/var/lib/mysql/myInit.txt" ]; then
	echo "Initializing MariaDB database :"
  

	# Launch the server in the background
	mysqld --user=mysql --skip-networking & PID=$!

	# Wait the server 
  until mysqladmin ping --silent; do
      echo "Waiting for MariaDB to start..."
      sleep 1
  done
	# Creat the database and the user
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MARIADB_DATABASE;"
  mysql -u root -e "CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_USER_PASSWORD';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON $MARIADB_DATABASE.* TO '$MARIADB_USER'@'%';"
  mysql -u root -e "FLUSH PRIVILEGES;"

  touch "/var/lib/mysql/myInit.txt"

	# Stop the server beofre restart it in the foreground
  mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
  wait $PID
  
  
	echo "MariaDB database is initialize"

else
  echo "MariaDB database is already initialize"
fi

exec mysqld --user=mysql