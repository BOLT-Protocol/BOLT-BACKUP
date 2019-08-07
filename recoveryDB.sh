#!/bin/bash
SSH_IP=tideops@ip-172-26-13-218
SSH_KEY_PATH=~/.ssh/id_rsa
ROOTFOLDER="/home/tideops/BackupDB"
remoteRecoveryDBfile="/home/tideops/BackupDB/$1"
USER_NAME="postgres"

main() {
  if [ -z $1 ]; then
    echo "\e[0;31mrequire recovery db file!!\e[0m"
    return
  fi
  if [ -z $2 ]; then
    echo "\e[0;31mrequire recovery dbname!!\e[0m"
    return
  fi
  echo "\e[0;32mrsync remote server!~\e[0m"
  rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete  ${SSH_IP}:${ROOTFOLDER}/* ${ROOTFOLDER}

  echo "\e[0;32mstart recovery db\e[0m"
  ssh -i ${SSH_KEY_PATH} ${SSH_IP} "pg_restore --dbname=$2 -U ${USER_NAME} --create --jobs=4 --verbose ${remoteRecoveryDBfile}"
}

main "$@"