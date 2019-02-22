#!/bin/bash

# Nom bdd Nextcloud
nc_bdd_name=nextcloud
nc_bdd_user=admin
nc_bdd_password=P@ssword
nc_bdd_host=localhost

ssh root@192.168.33.200 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'

ssh root@192.168.33.200 "mysqldump --single-transaction -h localhost -u $nc_bdd_user -password=$nc_bdd_password $nc_bdd_name" > /data/backup/nextcloud_bdd.sql

rsync -Aavx root@192.168.33.200:/var/www/html/nextcloud/ /data/backup/nextcloud-data/

