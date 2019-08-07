#!/bin/bash
SSH_IP=tideops@ip-172-26-13-218
SSH_KEY_PATH=~/.ssh/id_rsa
ROOTFOLDER="/home/tideops/BackupDB"
BACKUP_DBNAME1="trust_"$(date +"%Y_%m_%d_%H")".dmp"
BACKUP_DBNAME2="bolt_"$(date +"%Y_%m_%d_%H")".dmp"
USER_NAME="postgres"
KEEP_DAYS="90"

delete_old() {
  TOTAL=$(find ${ROOTFOLDER} -type f | wc -l)
  if [ $TOTAL -gt $KEEP_DAYS ]; then
    echo "\e[0;32delete old data ${ROOTFOLDER}/${DELETE_FILE} \e[0m"
    DELETE_FILE=$(ls -1 ${ROOTFOLDER} | head -n 1)
    rm -rf "${ROOTFOLDER}/${DELETE_FILE}"
  fi
}

main() {
  echo "\e[0;32mstart backup db!~ \e[0m"
  if [ ! -d $ROOTFOLDER ]; then
    mkdir -p $ROOTFOLDER
  fi

  ssh -i ${SSH_KEY_PATH} ${SSH_IP} "mkdir -p ${ROOTFOLDER}; echo '\e[0;32mplease enter db password!\e[0m' ;pg_dump -U ${USER_NAME}  -Fc trust > ${ROOTFOLDER}/${BACKUP_DBNAME1}; echo '\e[0;32mplease enter db password!\e[0m' ; pg_dump -U ${USER_NAME}  -Fc bolt > ${ROOTFOLDER}/${BACKUP_DBNAME2}"

  rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete  ${SSH_IP}:${ROOTFOLDER}/* ${ROOTFOLDER}

  delete_old
}

main "$@"