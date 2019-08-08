#!/bin/bash
SSH_IP=tideops@172.26.13.218
SSH_KEY_PATH=~/.ssh/id_rsa
ROOTFOLDER="BackupDB"
remoteRecoveryDBfile="/tmp/$1"
USER_NAME="postgres"

main() {
  if [ -z $1 ]; then
    echo "require recovery db file!!"
    return
  fi
  if [ -z $2 ]; then
    echo "require recovery dbname!!"
    return
  fi
  echo "start recoveryDB server!~"
  echo "scp dump data to remote server!~"
  scp -r -i ${SSH_KEY_PATH} -P 22 ${ROOTFOLDER}/$1 ${SSH_IP}:/tmp 

  echo "start recovery db"
  ssh -i ${SSH_KEY_PATH} -p 22 ${SSH_IP} "pg_restore --dbname=$2 -U ${USER_NAME} -h 127.0.0.1 --create --jobs=4 --verbose ${remoteRecoveryDBfile}"
  
  echo "rm remote data"
  ssh -i ${SSH_KEY_PATH} -p 22 ${SSH_IP} "rm -f ${remoteRecoveryDBfile}"

}

main "$@"
