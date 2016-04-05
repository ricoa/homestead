#!/usr/bin/env bash

# Pre Setup Scripts.

echo "vagrant    ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/80-webservice-init-users

/bin/sed -i 's/^zend_extension/;zend_extension/g' /etc/php/7.0/mods-available/xdebug.ini
/bin/sed -i 's/^zend_extension/;zend_extension/g' /etc/php/5.6/mods-available/xdebug.ini

mkdir -p /home/vagrant/etc/supervisor/conf.d
chown -R vagrant:vagrant /home/vagrant/etc/supervisor/conf.d
chmod -R g+rw /home/vagrant/etc/supervisor/conf.d

/bin/sed -i 's/files = /;files = /g' /etc/supervisor/supervisord.conf
/bin/sed -ie '$a files = /home/vagrant/etc/supervisor/conf.d/*.conf' /etc/supervisor/supervisord.conf

service supervisor restart
