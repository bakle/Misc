#! /bin/sh

#start Newrelic daemon
newrelic-daemon -c /usr/local/etc/newrelic/newrelic.cfg

#start PHP-FPM
/opt/bootstrap

newrelic_background_job(false);