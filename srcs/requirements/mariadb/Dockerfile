FROM debian:bookworm

# Install MariaDB server
RUN apt-get update -y && \
    apt-get install mariadb-server -y && \
    rm -rf /var/lib/apt/lists/*


# Copy custom configuration files if needed
COPY ./server.conf	/etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./init.sh		/usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

#Creat mysql user and set permissions
# RUN groupadd -r mysql
# RUN useradd -r -g mysql mysql
RUN  mkdir -p /run/mysqld && \
	chown -R mysql:mysql /run/mysqld && \
	mkdir -p /var/lib/mysql && \
	chown -R mysql:mysql /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /var/log/mysql


EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]
