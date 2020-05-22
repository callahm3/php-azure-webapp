FROM centos:7

# Install software
RUN set -eux; \
	yum install epel-release -y; \
	yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm; \
	yum install yum-utils -y; \
	yum-config-manager --enable remi-php73 -y; \ 
	yum update -y; \
	yum install -y \
	php \
	php-fpm \
	php-mcrypt \
	php-gd \
	php-ldap \
	php-soap \
	php-memcached \
	php-odbc \
	php-mysqli \
	php-pgsql \
	php-bcmath \
	php-odbc \
	php-xmlreader \
	php-xmlrpc \
	php-ctype \
	php-mbstring \
	php-xml; \
	yum install -y \
	zip \
	unzip \
	php-zip \
	nginx \
	wget \
	openssh-server \
	openssh-client \
	memcached \ 
	git \
	pgbouncer \
	supervisor \ 
	ImageMagick; \
	yum clean all -y \
	;

# Enable new php installation
#RUN 

# Enable Azure SSH access
RUN set -eux; \
	echo 'root:Docker!' | chpasswd; \
	ssh-keygen -A \
	;

# Create directories
RUN set -eux; \
	mkdir -p /dockerfiles/; \
	mkdir -p /var/www/html; \
	mkdir -p /etc/ssh; \
	mkdir -p /etc/nginx-cache \
	mkdir -p /elasticsearch \
	;

# Install elasticsearch through archive method
RUN set -eux; \
	cd /elasticsearch; \
	wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.7.0-linux-x86_64.tar.gz; \
	tar -xzf elasticsearch-7.7.0-linux-x86_64.tar.gz \
	;

# Install composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/4d7f8d40f9788de07c7f7b8946f340bf89535453/web/installer -O - -q | php -- --quiet --install-dir=/usr/local/bin

# change ownership to nginx
RUN set -eux; \
	chown -R nginx:nginx /var/www/; \
	chown -R nginx:nginx /run; \
	chown -R nginx:nginx /var/lib/nginx; \
	chown -R nginx:nginx /var/log/nginx; \
	chown -R nginx:nginx /etc/nginx-cache \
	;

# Copy configuration files
COPY docker-entrypoint.sh /dockerfiles/docker-entrypoint.sh
COPY config/sshd_config /etc/ssh/sshd_config
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php-fpm.d/www.conf
COPY config/php.ini /etc/php.d/custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/userlist.txt /etc/pgbouncer/userlist.txt
COPY config/custom_pgbouncer.ini /etc/pgbouncer/custom_pgbouncer.ini

# Set html directory as default pwd
WORKDIR /var/www/html

# expose web port and ssh port
EXPOSE 8080 2222

ENTRYPOINT [ "/dockerfiles/docker-entrypoint.sh" ]