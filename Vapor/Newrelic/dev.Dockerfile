FROM laravelphp/vapor:php80

# Descarga e instalación de newrelic: https://download.newrelic.com/php_agent/release/
RUN \
    curl -L "https://download.newrelic.com/php_agent/release/newrelic-php5-9.18.1.303-linux-musl.tar.gz" | tar -C /tmp -zx && \
    export NR_INSTALL_USE_CP_NOT_LN=1 && \
    export NR_INSTALL_SILENT=1 && \
    /tmp/newrelic-php5-*/newrelic-install install

# El archivo .export es generado desde el pipeline para obtener las variables desde bitbucket
COPY ./.export ./.export

# Añadimos las varibles de entorno y las setteamos al archivo php.ini
RUN source .export  && \
    echo $' \n\
    extension = "newrelic.so" \n\
    newrelic.logfile = "/dev/null" \n\
    newrelic.loglevel = "error" \n\
    newrelic.appname = "'${NEWRELIC_APP_NAME}'"' >> /usr/local/etc/php/php.ini \
    $' \n\
    newrelic.license = "'${NEWRELIC_LICENSE_KEY}'"' >> /usr/local/etc/php/php.ini

# se eliminan archivos de instalación
RUN rm /usr/local/etc/php/conf.d/newrelic.ini

RUN mkdir -p /usr/local/etc/newrelic && \
  echo "loglevel=error" > /usr/local/etc/newrelic/newrelic.cfg && \
  echo "logfile=/dev/null" >> /usr/local/etc/newrelic/newrelic.cfg

COPY . /var/task

USER root
RUN chmod +x /var/task/entrypoint.sh
ENTRYPOINT ["/var/task/entrypoint.sh"]
