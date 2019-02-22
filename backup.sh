SHELL=/bin/bash

## VARIABLES
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
NEXTCLOUD_SERVER_IP='192.168.33.200'
NEXTCLOUD_BACKUP_USER='user'
### SCRIPT
## ETAPE DE COPIE
echo "Etape 1"
# Activation du mode maintenance nextcloud
ssh user@192.168.33.200 'sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on'
echo "Etape 2"
#dumb
ssh user@192.168.33.200 "mysqldump --single-transaction -h localhost -u $NC_BDD_USER -password=$NC_BDD_PASSWORD $NC_BDD_NAME" > /data/backup/nextclouddb.sql
# Réaliser la copie
rsync -Aavx user@192.168.33.200:/var/www/html/nextcloud/ /data/backup/nextcloud_dir
# Désactivation du mode maintenance nextcloud
ssh user@192.168.33.200 "sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off"
echo "###### FIN DE LA COPIE LOCALE ######"
## ETAPE DE NETTOYAGE COTE NEXTCLOUD
echo "###### SUPPRESSION DU DUMP SQL SUR NEXTCLOUD######"
ssh user@192.168.33.200 'rm ~/$NC_BACKUP_FILE'
## ETAPE DE NETTOYAGE COTE BACKUP
find /data/backup -name "*.sql" -mtime +${NC_BAKCUP_TIME} -print -exec rm -f {} \;
## FIN
echo "###################### FIN DE LA SAUVEGARDE ######################"
