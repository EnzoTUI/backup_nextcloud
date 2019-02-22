#!/bin/bash
#Temps de rétention des sauvegardes
NC_BAKCUP_TIME=30
#Nom bdd Nextcloud
NC_BDD_NAME=nextcloud
#User bdd Nextcloud
C_BDD_USER=admin
# Mot de passe bdd Nextcloud
NC_BDD_PASSWORD=P@ssw0rd
NC_BDD_HOST=localhost
databackup=nextcloud_`date +"%Y.%m.%d"`.sql
echo "Etape 1"
# Activation du mode maintenance nextcloud
ssh root@192.168.33.200 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'
echo "Etape 2"
ssh root@192.168.33.200 "mysqldump --single-transaction -h localhost -u $NC_BDD_USER -password=$NC_BDD_PASSWORD $NC_BDD_NAME" > /data/backup/nextcloud-sql.bak
# Réaliser la copie
rsync -Aavx -e "ssh" root@192.168.33.200:/var/www/html/nextcloud/ /data/backup/nextcloud-data
zfs snapshot data/backup@nextcloud_`date +"%Y.%m.%d"`
while [[ `zfs list -H -t snapshot -o name | wc -l` -gt 30 ]]; do
	zfs destroy `zfs list -H -t snapshot -o name | head -1`
done
# Désactivation du mode maintenance nextcloud
ssh root@192.168.33.200 "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
echo "###### FIN DE LA COPIE LOCALE ######"
echo "###################### FIN DE LA SAUVEGARDE ######################"
