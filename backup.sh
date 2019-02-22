SHELL=/bin/bash

# Temps de rétention des sauvegardes
NC_BAKCUP_TIME=30
# Nom bdd Nextcloud
NC_BDD_NAME='nextcloud'
# User bdd Nextcloud
NC_BDD_USER='admin'
# Mot de passe bdd Nextcloud
NC_BDD_PASSWORD='P@ssw0rd'
NC_BDD_HOST='localhost'
# IP du Serveur de Backup

echo "Etape 1"
# Activation du mode maintenance nextcloud
ssh user@192.168.33.200 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'
echo "Etape 2"
#dumb
ssh user@192.168.33.200 "mysqldump --single-transaction -h localhost -u $NC_BDD_USER -password=$NC_BDD_PASSWORD $NC_BDD_NAME" > /data/backup/nextcloud_`date + "%Y%m%d"`.sql
# Réaliser la copie
rsync -Aavx user@192.168.33.200:/var/www/html/nextcloud/ /data/backup/nextcloud_`date + "%Y%m%d"`/
# Désactivation du mode maintenance nextcloud
ssh user@192.168.33.200 "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
echo "###### FIN DE LA COPIE LOCALE ######"
echo "###################### FIN DE LA SAUVEGARDE ######################"
