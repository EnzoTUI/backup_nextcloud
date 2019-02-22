#!/bin/bash

MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASS=root
MYSQL_DBNAME=nextcloud

echo "Entrez la date de restauration voulu"
read date

# Arrêt du service Nextcloud sur le serveur
ssh root@192.168.33.200 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'

# Verrouillage de la snapshot
# zfs hold keep data/backup@nextcloud_$date

# Clone de la snapshot
zfs clone data/backup@nextcloud_$date data/restore

# Restauration des fichiers du serveur NextCloud
rsync -Aavx /data/restore/nextcloud-data/ -e "ssh" root@192.168.33.200:/var/www/html/nextcloud/
# Nettoyage de la BDD avant restauration
ssh root@192.168.33.200  "mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e \"DROP DATABASE $MYSQL_DBNAME\""
ssh root@192.168.33.200  "mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e \"CREATE DATABASE $MYSQL_DBNAME\""

# Restauration de la BDD du serveur NextCloud
ssh root@192.168.33.200 "mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS $MYSQL_DBNAME" < /data/restore/nextcloud-bdd.bak

# Suppression du clone de la snapshot
zfs destroy data/restore
# Déverrouillage de la snapshot
zfs release keep data/backup@nextcloud_$date
# Redémarrage du service Nextcloud sur le serveur
ssh root@192.168.33.200 "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
