#!/bin/bash
SSH_IP=tideops@172.26.13.218
SSH_KEY_PATH=~/.ssh/id_rsa
ROOTFOLDER="BackupDB"
BACKUP_DBNAME1="trust_"$(date +"%Y_%m_%d_%H")".dmp"
BACKUP_DBNAME2="bolt_"$(date +"%Y_%m_%d_%H")".dmp"
USER_NAME="postgres"
USER_PASSWORD=""
BACKUP_AMOUNT="90"
LOG_PATH="backuplog"

delete_old() {
  TOTAL=$(find ${ROOTFOLDER} -type f | wc -l)
  if [ $TOTAL -gt $BACKUP_AMOUNT ]; then
    echo "delete old data ${ROOTFOLDER}/${DELETE_FILE} " 1>> ${LOG_PATH}/backupDB.log 2>> ${LOG_PATH}/backupDB.err.log
    DELETE_FILE=$(ls -1 ${ROOTFOLDER} | head -n 1)
    rm -rf "${ROOTFOLDER}/${DELETE_FILE}"
  fi
}

main() {
  if [ ! -d $LOG_PATH ]; then
    mkdir -p $LOG_PATH
  fi

  echo "$(date +"%Y_%m_%d_%H:%M:%S") ===== start backup db!~ =====" 2>&1 | tee -a ${LOG_PATH}/backupDB.log >> ${LOG_PATH}/backupDB.err.log
  if [ ! -d $ROOTFOLDER ]; then
    mkdir -p $ROOTFOLDER
  fi

  ssh -i ${SSH_KEY_PATH} ${SSH_IP} -p 22 "mkdir -p ${ROOTFOLDER}; echo 'please enter db password!' ;pg_dump -U ${USER_NAME} -h 127.0.0.1 -Fc trust > ${ROOTFOLDER}/${BACKUP_DBNAME1};" 1>> ${LOG_PATH}/backupDB.log 2>> ${LOG_PATH}/backupDB.err.log<<EOF
${USER_PASSWORD}
EOF

  ssh -i ${SSH_KEY_PATH} ${SSH_IP} -p 22 "echo 'please enter db password!' ; pg_dump -U ${USER_NAME} -h 127.0.0.1 -Fc bolt > ${ROOTFOLDER}/${BACKUP_DBNAME2}" 1>> ${LOG_PATH}/backupDB.log 2>> ${LOG_PATH}/backupDB.err.log<<EOF
${USER_PASSWORD}
EOF

  
  echo "scp file to local!~" 1>> ${LOG_PATH}/backupDB.log 2>> ${LOG_PATH}/backupDB.err.log
  scp -r -i ${SSH_KEY_PATH} -P 22 ${SSH_IP}:/home/tideops/${ROOTFOLDER}/* ${ROOTFOLDER}/

  ssh -i ${SSH_KEY_PATH} ${SSH_IP} -p 22 "rm -rf ${ROOTFOLDER}"
  delete_old
  echo "$(date +"%Y_%m_%d_%H:%M:%S") ===== backup db finish!~ =====" 2>&1 | tee -a ${LOG_PATH}/backupDB.log >> ${LOG_PATH}/backupDB.err.log
}

main "$@"
