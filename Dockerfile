FROM alpine:3.21
RUN apk update && \
	apk add --no-cache apache2 php84-apache2 php84-mysqli php84-session php84-curl php84-gd php84-iconv php84-mbstring php84-xml php84-pecl-imagick php84-intl php84-zip && \
	rm -rf /var/cache/apk/*

# Set ServerName and disable logs on Apache server
RUN echo "ServerName localhost" >> /etc/apache2/httpd.conf
RUN /bin/sed -i 's/^\(\s*\)\(CustomLog.*\)/\1#\2/' /etc/apache2/httpd.conf
RUN /bin/sed -i 's/^\(\s*\)\(ErrorLog.*\)/\1#\2/' /etc/apache2/httpd.conf

# Set PHP parameters
COPY ./php/99_ianseo.ini /etc/php84/conf.d

# Create VirtualHost
COPY ./apache/ianseo.conf /etc/apache2/conf.d

# Get I@NSEO and set required permissions
RUN mkdir /var/www/localhost/htdocs/ianseo
RUN /usr/bin/wget -P /tmp https://www.ianseo.net/Release/Ianseo_20241208.zip
RUN /usr/bin/unzip -d /var/www/localhost/htdocs/ianseo /tmp/Ianseo_20241208.zip
RUN chown -R apache:apache /var/www/localhost/htdocs/ianseo
RUN chmod -R 777 /var/www/localhost/htdocs/ianseo

EXPOSE 80
CMD ["httpd", "-D", "FOREGROUND"]
