#!/bin/bash

# Check the required environment variables



if [ ! -f "/var/lib/mysql/myInit.txt" ]; then
	echo "Initializing MariaDB database :"


  #test existance and not empty
  : ${MARIADB_ROOT_USER:?"MARIADB_ROOT_USER is not set"}
  : ${MARIADB_ROOT_PWD:?"MARIADB_ROOT_PWD is not set"}
  : ${MARIADB_DATABASE:?"MARIADB_DATABASE is not set"}
  : ${MARIADB_USER:?"MARIADB_USER is not set"}
  : ${MARIADB_USER_PWD:?"MARIADB_USER_PWD is not set"}


  #test for invalid characters
  ## --- MARIADB_ROOT_USER (type: user)
  case "$MARIADB_ROOT_USER" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "MARIADB_ROOT_USER contains invalid characters" >&2; exit 1 ;;
  esac

  # --- MARIADB_ROOT_PWD (type: password)
  case "$MARIADB_ROOT_PWD" in
    (*[!a-zA-Z0-9!@#%^_+\-=:.,?]*|"") echo "MARIADB_ROOT_PWD contains invalid characters" >&2; exit 1 ;;
  esac

  # --- MARIADB_DATABASE (type: database name)
  case "$MARIADB_DATABASE" in
    (*[!a-zA-Z0-9_]*|"") echo "MARIADB_DATABASE contains invalid characters" >&2; exit 1 ;;
  esac

  # --- MARIADB_USER (type: user)
  case "$MARIADB_USER" in
    (*[!a-zA-Z0-9_.@-]*|"") echo "MARIADB_USER contains invalid characters" >&2; exit 1 ;;
  esac

  # --- MARIADB_USER_PWD (type: password)
  case "$MARIADB_USER_PWD" in
    (*[!a-zA-Z0-9!@#%^_+\-=:.,?]*|"") echo "MARIADB_USER_PWD contains invalid characters" >&2; exit 1 ;;
  esac

	# Launch the server in the background
	mysqld --user=mysql --skip-networking & PID=$!

	# Wait the server
  i=0
  until mysqladmin ping --silent; do
      if [ $i == 10 ]; then
        echo "MariaDB no respsonse -- Exit"
        exit 1
      fi
      echo "Waiting for MariaDB to start..."
      sleep 1
      let i++
  done

	# Creat the database and the user
  mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MARIADB_ROOT_USER}'@'%' IDENTIFIED BY '${MARIADB_ROOT_PWD}';
GRANT ALL PRIVILEGES ON *.* TO '${MARIADB_ROOT_USER}'@'%' WITH GRANT OPTION;


CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_USER_PWD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';


ALTER USER '${MARIADB_ROOT_USER}'@'%' IDENTIFIED BY '${MARIADB_ROOT_PWD}';
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('sminot147');

DELETE FROM mysql.user WHERE User='';

DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test_%';

FLUSH PRIVILEGES;

EOF



  touch "/var/lib/mysql/myInit.txt"

	# Stop the server beofre restart it in the foreground
  mysqladmin -u root -p"${MARIADB_ROOT_PWD}" shutdown
  wait $PID


	echo "MariaDB database is initialize"

else
  echo "MariaDB database is already initialize"
fi

exec mysqld --user=mysql
