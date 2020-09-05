#!/bin/sh -x

# From instruction https://peteris.rocks/blog/unattended-installation-of-wordpress-on-ubuntu-server

# Variables
WP_DOMAIN="wordpress.$SERVER_NAME"
WP_DB_NAME="wordpress"
MYSQL_ROOT_PASSWORD="root"

# Configure MySQL
service mysql start

mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE USER '$WP_DB_USERNAME'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
CREATE DATABASE $WP_DB_NAME;
GRANT ALL ON $WP_DB_NAME.* TO '$WP_DB_USERNAME'@'localhost';
EOF

tee $ROOT_PATH/wordpress/wp-config.php <<EOF
<?php

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '$WP_DB_NAME' );

/** MySQL database username */
define( 'DB_USER', '$WP_DB_USERNAME' );

/** MySQL database password */
define( 'DB_PASSWORD', '$WP_DB_PASSWORD' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

define( 'DB_CHARSET', 'utf8mb4' );

define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         'ajshkahsKJHASDKJH12873912873918723978Aajkhdakljhsdkajhdkjahskdjha' );
define( 'SECURE_AUTH_KEY',  'jahskfjaskdh2893792378safkajhsdfkh293874298ukksjadhfkjasdfjkh2983' );
define( 'LOGGED_IN_KEY',    'jasjhdfbJHBJHASBDJHBjahbsdkbdakfalsmfj32984u23984uosifjaskdfakjsh' );
define( 'NONCE_KEY',        '987923874fhsadjkfhkajsdfjkhgwjefhgJHGDJAHGDSJAHGSDJHGasdjgajdhgww' );
define( 'AUTH_SALT',        '92839283uhJHDKAJHSDKJAHSDKHJakjhdkajhsdkjHKAJHSDKAJHSDKAJHSKJHDKj' );
define( 'SECURE_AUTH_SALT', 'jkashfkhskhkasjdkajhsdKJHAKSDJHAKJSHDkajhsdkahsdkjhaskjdhakjshdka' );
define( 'LOGGED_IN_SALT',   'aklsjdlKJASHDKAHDKAHSdkahskdjhkjashdfkhaskdfhkjHKJHSFKJSHFKJSHDKJ' );
define( 'NONCE_SALT',       'kajhsdkjahKJHAKSJDHAKJSHDKAJHSDKAJHSDKJAHSKJDHAKHSDkjhaskdjhakjss' );

\$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';

EOF

tee /etc/nginx/sites-available/$SERVER_NAME <<EOF
server {
  listen 80;
  listen 443 default ssl;

  server_name $SERVER_NAME www.$SERVER_NAME;

  #ssl on;
  ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
  ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
  
  index index.php index.html index.htm;

  root $ROOT_PATH ;
 
  location / {
    autoindex $AUTOINDEX;
    try_files \$uri \$uri/ =404;
  }

  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php7.3-fpm.sock;
  }
}
EOF

rm -f /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/$SERVER_NAME /etc/nginx/sites-enabled/$SERVER_NAME

service php7.3-fpm start
service nginx restart

  curl --insecure "https://localhost/wordpress/wp-admin/install.php?step=2" \
  --data-urlencode "weblog_title=$WP_DOMAIN"\
  --data-urlencode "user_name=$WP_ADMIN_USERNAME" \
  --data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
  --data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
  --data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
  --data-urlencode "pw_weak=on" \
  --data-urlencode "blog_public=0"  

bash