FROM debian:bookworm


RUN apt-get update -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get install php 

#Install Wordpress-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /var/www/wordpress




# Copy custom configuration files if needed
COPY ./init.sh		/usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh



EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init.sh"]
