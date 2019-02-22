#!/bin/bash

## VARIABLES

currentDate=$(date +"%Y%m%d")

# Répertoire de backup
NC_BACKUP_DIR="nextcloud_${currentDate}"

# Répertoire de logs de backup
NC_BACKUP_DIR_LOGS="/home/user/backup/nextcloud/logs/"
exec &> ${LOGDIR}/out.log

# Fichier de Backup
NC_BACKUP_FILE="nextcloud_${currentDate}.sql"

# Temps de rétention des sauvegardes
NC_BAKCUP_TIME=30

# Nom bdd Nextcloud
NC_BDD_NAME="nextcloud"

# User bdd Nextcloud
NC_BDD_USER="admin"

# Mot de passe bdd Nextcloud
NC_BDD_PASSWORD="P@ssw0rd"

# IP du Serveur de Backup
NEXTCLOUD_SERVER_IP="192.168.33.200"
NEXTCLOUD_BACKUP_USER="user"

### SCRIPT

	## ETAPE DE COPIE

		# Activation du mode maintenance nextcloud
		ssh ${NEXTCLOUD_BACKUP_USER}@${NEXTCLOUD_SERVER_IP} 'sudo -u www-data /usr/bin/php /var/www/html/nextcloud/occ maintenance:mode --on'

		#dumb 
		ssh ${NEXTCLOUD_BACKUP_USER}@${NEXTCLOUD_SERVER_IP} "mysqldump --single-transaction -u $NC_BDD_USER -p$NC_BDD_PASSWORD $NC_BDD_NAME > ~/$NC_BACKUP_FILE"

		# Réaliser la copie
		rsync -avx ${NEXTCLOUD_BACKUP_USER}@${NEXTCLOUD_SERVER_IP}:/var/www/html/nextcloud/ /data/backup/${NC_BACKUP_DIR}/
		rsync -avx ${NEXTCLOUD_BACKUP_USER}@${NEXTCLOUD_SERVER_IP}:/home/user/$NC_BACKUP_FILE /data/backup/${NC_BACKUP_FILE}


		# Désactivation du mode maintenance nextcloud
		ssh $NEXTCLOUD_BACKUP_USER@$NEXTCLOUD_SERVER_IP php occ maintenance:mode --off

		echo "###### FIN DE LA COPIE LOCALE ######"


	## ETAPE DE NETTOYAGE COTE NEXTCLOUD

		echo "###### SUPPRESSION DU DUMP SQL SUR NEXTCLOUD######"
		ssh ${NEXTCLOUD_BACKUP_USER}@${NEXTCLOUD_SERVER_IP} 'sudo rm ~/$NC_BACKUP_FILE'

	## ETAPE DE NETTOYAGE COTE BACKUP
	find /data/backup -name "*.sql" -mtime +${NC_BAKCUP_TIME} -print -exec rm -f {} \;

	## FIN
		echo "###################### FIN DE LA SAUVEGARDE ######################"