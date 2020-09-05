FROM debian:buster

# UPDATE AND UPGRADE
RUN apt-get update
RUN apt-get -y upgrade

# INSTALL NGINX
RUN apt-get -y install nginx

# INSTALL MYSQL
RUN apt-get -y install mariadb-server

# INSTALL PHP
RUN apt-get -y install php7.3 php-mysql php-fpm php-mbstring

# INSTALL TOOLS
RUN apt-get -y install wget curl

# GET WORDPRESS and PHPMYADMIN
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz -O /tmp/phpmyadmin.tar.gz

ENV ROOT_PATH="/var/www/site"

RUN mkdir -p $ROOT_PATH/phpmyadmin; \
	cd $ROOT_PATH/phpmyadmin; \
	tar xvzf /tmp/phpmyadmin.tar.gz --strip-components 1
RUN mkdir -p $ROOT_PATH/wordpress ;\
	cd $ROOT_PATH/wordpress ;\
	tar xvzf /tmp/wordpress.tar.gz --strip-components 1
RUN rm /tmp/wordpress.tar.gz ;\
	rm /tmp/phpmyadmin.tar.gz
RUN chown -R www-data:www-data $ROOT_PATH/wordpress/; \
	chmod -R 777 $ROOT_PATH/wordpress/wp-content

ENV SERVER_NAME="kallard.site"
ENV AUTOINDEX="on"
ENV WP_ADMIN_USERNAME="admin"
ENV WP_ADMIN_PASSWORD="admin"
ENV WP_DB_USERNAME="kallard"
ENV WP_DB_PASSWORD="kallard"
ENV WP_ADMIN_EMAIL="kallard@student.21-school.ru"

# SSL
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-subj "/C=ru/ST=Moscow/L=Moscow/O=no/OU=no/CN=localhost/" \
	-keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

EXPOSE 80 443

COPY srcs/init.sh . 
CMD sh -x init.sh
