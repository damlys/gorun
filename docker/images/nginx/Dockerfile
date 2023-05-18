FROM nginx:1.24-bullseye
USER root:root
WORKDIR /
ENTRYPOINT []
CMD ["nginx"]
EXPOSE 80

RUN rm -rf \
  /.dockerenv \
  /docker-entrypoint.d \
  /docker-entrypoint.sh \
  /etc/nginx/conf.d/* \
  /etc/nginx/nginx.conf \
  /usr/share/nginx/html/*
COPY etc/nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html
