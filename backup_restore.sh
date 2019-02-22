#!/bin/bash

#Varriables
NomBDD=nextcloud
Utilisateur=root
pswd=root
Host=root@192.168.33.200


echo "Renseignez la date de la restauration"
read date

# Mise en maintenance du service Nextcloud
ssh $Host 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'

# Récupération du contenu de notre snapshot
zfs clone data/backup@nextcloud_$date data/restore

# Nettoyage de la base de données avant la restauration
ssh $Host  "mysql -h localhost -u $Utilisateur --password=$pswd -e \"DROP DATABASE $NomBDD\""
ssh $Host  "mysql -h localhost -u $Utilisateur --password=$pswd -e \"CREATE DATABASE $NomBDD\""

# Restauration des fichiers du service NextCloud
rsync -Aavx /data/restore/nextcloud-data/ -e "ssh" $Host:/var/www/html/nextcloud/

# Restauration de la base de données du service NextCloud
ssh $Host "mysql -h localhost -u $Utilisateur --password=$pswd $NomBDD" < /data/restore/nextcloud_bdd.bak

# Suppression du contenu de notre snapshot
zfs destroy data/restore

# Arrêt de la maintenance et redémarrage du service Nextcloud
ssh $Host "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
