#!/bin/bash

# Check the required environment variables
#test existance and not empty
# : ${MARIADB_ROOT_PASSWORD:?"MARIADB_ROOT_PASSWORD is not set"}
# : ${MARIADB_DATABASE:?"MARIADB_DATABASE is not set"}
# : ${MARIADB_USER:?"MARIADB_USER is not set"}
# : ${MARIADB_USER_PASSWORD:?"MARIADB_USER_PASSWORD is not set"}


# #test for invalid characters
# case "$MARIADB_ROOT_PASSWORD" in
#   (*[!!-~]*|"") echo "MARIADB_ROOT_PASSWORD contains invalid characters" >&2; exit 1 ;;
# esac

# case "$MARIADB_USER_PASSWORD" in
#   (*[!!-~]*|"") echo "MARIADB_USER_PASSWORD contains invalid characters" >&2; exit 1 ;;
# esac

# case "$MARIADB_USER" in
#   (*[!a-zA-Z0-9_]*|"") echo "MARIADB_USER contains invalid characters" >&2; exit 1 ;;
# esac

# case "$MARIADB_DATABASE" in
#   (*[!a-zA-Z0-9_]*|"") echo "MARIADB_DATABASE contains invalid characters" >&2; exit 1 ;;
# esac


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
  mariadb -u root <<EOF
CREATE USER IF NOT EXISTS '${MYSQL_ROOT_USER}'@'%' IDENTIFIED BY '${MYSQL_ROOT_PWD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ROOT_USER}'@'%' WITH GRANT OPTION;
ALTER USER '${MYSQL_ROOT_USER}'@'%' IDENTIFIED BY '${MYSQL_ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PWD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test_%';
FLUSH PRIVILEGES;
EOF

# ------------------------------------------------------------------------------------------------ne focntonne pas chez moi
# ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PWD}');


  touch "/var/lib/mysql/myInit.txt"

	# Stop the server beofre restart it in the foreground
  mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
  wait $PID


	echo "MariaDB database is initialize"

else
  echo "MariaDB database is already initialize"
fi

exec mysqld --user=mysql
