FROM debian:bookworm


RUN apt update -y 
    # rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd php8.2-xml php8.2-mbstring php8.2-zip && apt-get clean

RUN    apt-get install curl -y &&\
    apt-get clean        

RUN apt-get install curl -y && \
    apt-get install -y less


WORKDIR /var/www/html

COPY init-wordpress.sh /init-wordpress.sh
RUN chmod +x /init-wordpress.sh

ENTRYPOINT ["/init-wordpress.sh"]
