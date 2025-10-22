FROM debian:bookworm


RUN apt-get update -y && \
    apt-get install -y php8.2-fpm php8.2-mysql curl netcat-openbsd && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    apt-get clean

COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

COPY init-wordpress.sh /init-wordpress.sh
RUN chmod +x /init-wordpress.sh

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf  && \
   sed -i 's|;clear_env = no|clear_env = no|' /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

ENTRYPOINT ["/init-wordpress.sh"]
