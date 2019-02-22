#!/bin/bash

#Varriables
NomBDD=nextcloud
Utilisateur=root
pswd=root
Host=root@192.168.33.200


# Mise en maintenance du service Nextcloud
ssh $Host 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'

# Récupération des fichiers data du service Nextcloud
rsync -Aavx -e "ssh" $Host:/var/www/html/nextcloud/ /data/backup/nextcloud-data/

# Dump de la base de données mysql
ssh $Host "mysqldump --single-transaction -h localhost -u $nc_bdd_user --password=$nc_bdd_password $nc_bdd_name" > /data/backup/nextcloud_bdd.bak

# Réalisation d'une snapshot avec la date du jour dans son nom
zfs snapshot data/backup@nextcloud_`date +"%Y.%m.%d"`

# Suppression des snapshots de plus de 30 jours
limite="data/backup@nextcloud_`date --date='-30 day' +"%Y.%m.%d"`"
for snap in `zfs list -H -t snapshot -o name` ; do
	if [[ $snap < $limite ]]; then
		zfs destroy $snap
	fi
done

# Arrêt de la maintenance et redémarrage du service Nextcloud
ssh $Host 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off'

# Sauvegarde terminée