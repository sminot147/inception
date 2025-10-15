FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install nginx -y && \
    rm -rf /var/lib/apt/lists/*

COPY ./nginx.conf /etc/nginx/nginx.conf


EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]