FROM node:lts-alpine
# INSTALL PHP8.0
RUN apk add php81 php81-fpm php81-xml php81-gd php81-zip php81-mbstring php81-curl php81-mysqli php81-bcmath php81-phar php81-tokenizer php81-fileinfo php81-xmlwriter php81-xmlreader php81-simplexml php81-pdo php81-iconv php81-session

RUN apk add bash
RUN apk add curl
RUN apk add git
RUN apk add supervisor

# INSTALL COMPOSER
RUN curl -sS https://getcomposer.org/installer | php81 -- --install-dir=/usr/bin --filename=composer


# CLONE NEXOPOS REPOSITORY
RUN git clone https://github.com/Blair2004/NexoPOS
WORKDIR NexoPOS

#INSTALL DEPENDENCIES
RUN composer install
RUN npm install
RUN composer dump-autoload
RUN php artisan key:generate

#BUILDING FRONTEND
RUN npm run prod

# INSTALL NGINX TO SERVE
RUN apk add nginx

COPY server/etc/nginx /etc/nginx
COPY server/etc/php /etc/php81


#COPY CONTENT TO WWW FOLDER
RUN mkdir /usr/share/nginx/html
RUN mv /NexoPOS/* /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

RUN mkdir /var/run/php
RUN php-fpm81
COPY server/.env .env
RUN chmod -R 777 /usr/share/nginx/html/*
RUN php artisan key:generate
RUN php artisan storage:link --force

EXPOSE 80

CMD ["/bin/bash", "-c", "php-fpm81 && chmod 777 /var/run/php/php8-fpm.sock && nginx -g 'daemon off;'"]
