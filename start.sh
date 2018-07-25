#!/bin/bash

/usr/bin/supervisord -c /etc/supervisord.conf

if [ ! -f /home/magento/readme.txt ]; then
    # mysql has to be started this way as it doesn't work to call from /etc/init.d
    # /usr/bin/mysqld_safe &
    sleep 10s
    # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
    ROOT_PASSWORD="root" # `pwgen -c -n -1 12`
    MYSQL_ROOT_PASSWORD="root"
    MYSQL_MAGENTO_PASSWORD="magento"
    MAGENTO_PASSWORD="magento"
    echo "magento:$MAGENTO_PASSWORD" | chpasswd
    echo "root:$ROOT_PASSWORD" | chpasswd

    mysql -uroot < /usr/share/phpmyadmin/sql/create_tables.sql
    mysql -uroot -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'%' IDENTIFIED BY 'pmapass' WITH GRANT OPTION;"
    mysql -uroot -e "CREATE DATABASE magento; GRANT ALL PRIVILEGES ON magento.* TO 'magento'@'localhost' IDENTIFIED BY '$MYSQL_MAGENTO_PASSWORD'; FLUSH PRIVILEGES;"
    mysql -uroot -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;FLUSH PRIVILEGES;"
    mysqladmin -u root password $MYSQL_ROOT_PASSWORD
    # pkill -9 mysql
    # mv /var/lib/mysql/ibdata1 /var/lib/mysql/ibdata1.bak
    # cp -a /var/lib/mysql/ibdata1.bak /var/lib/mysql/ibdata1
fi

if [ ! -f /home/magento/readme.txt ]; then
    echo -e "Address\t\t: http://`networkctl status | awk '/Address/ {print $2}'`" >> /home/magento/readme.txt
    echo -e "Web Directory\t: /home/magento/files/html" >> /home/magento/readme.txt
    echo -e "SSH/SFTP User\t: magento/magento" >> /home/magento/readme.txt
    echo -e "ROOT User\t: root/root" >> /home/magento/readme.txt
    echo -e "Database Host\t: localhost" >> /home/magento/readme.txt
    echo -e "Database Name\t: magento" >> /home/magento/readme.txt
    echo -e "Database User\t: magento/magento" >> /home/magento/readme.txt
    echo -e "DB ROOT User\t: root/root" >> /home/magento/readme.txt
    echo -e "phpMyAdmin\t: http://`networkctl status | awk '/Address/ {print $2}'`/phpmyadmin" >> /home/magento/readme.txt
fi

cat /home/magento/readme.txt
/usr/sbin/sshd -De