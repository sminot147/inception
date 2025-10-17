FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y openssl nginx  && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /etc/nginx/ssl/ && \
    openssl genrsa -out /etc/nginx/ssl//server.key 2048 && \
    openssl req -new -x509 -key /etc/nginx/ssl//server.key \
        -out /etc/nginx/ssl//server.crt \
        -days 365 \
        -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=Inception/CN=localhost"

COPY ./nginx.conf /etc/nginx/conf.d


EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
