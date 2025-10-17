FROM debian:bookworm


RUN apt update -y
    # rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y php8.2-fpm php8.2-mysql curl netcat-openbsd && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    apt-get clean


# php8.2-curl php8.2-gd php8.2-xml php8.2-mbstring php8.2-zip
# apt-get install -y less && \


COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf


WORKDIR /var/www/html

COPY init-wordpress.sh /init-wordpress.sh
RUN chmod +x /init-wordpress.sh

ENTRYPOINT ["/init-wordpress.sh"]
