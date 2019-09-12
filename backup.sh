#!/bin/bash
BOLT_SSH_IP=172.26.13.218
APIGATEWAY_SSH_IP=172.26.0.201
HOWINVEST_SSH_IP=172.26.8.110
SSH_KEY_PATH=~/.ssh/id_rsa
HOME="/home/tideops"
ROOTFOLDER="/extra_data/Backup"
FOLDER="${ROOTFOLDER}/BOLT_"$(date +"%Y_%m_%d_%H")
SYNC_FOLDER="/extra_data/BOLT_SYNC_FOLDER"
BACKUP_AMOUNT="300"
LOG_PATH="/extra_data/backuplog"
RESULT="Backup Success."

sync() {
  list=$1
  IFS=";"
  for i in "${list[@]}"
  do
    read -a arr <<< "${i}"
    plateform="${arr[0]}"
    name="${arr[1]}"
    path="${arr[2]}"
    echo "rsync ${name} data" 2>&1 | tee -a ${LOG_PATH}/backup.log >> ${LOG_PATH}/backup.err.log
    if [ $plateform == "bolt1" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/${name}  ${BOLT_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False leveldb"
      fi
    elif [ $plateform == "bolt2" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/ ${BOLT_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False env, config"
      fi
    elif [ $plateform == "howninvest1" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/${name}  ${HOWINVEST_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False leveldb"
      fi
    elif [ $plateform == "howninvest2" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/ ${HOWINVEST_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False leveldb"
      fi
    elif [ $plateform == "apigateway1" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/${name}  ${APIGATEWAY_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False leveldb"
      fi
    elif [ $plateform == "apigateway2" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH} -p 22" --delete --backup --backup-dir=$FOLDER/ ${APIGATEWAY_SSH_IP}:${path} ${SYNC_FOLDER}/${name} 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
      if [ "$?" != "0" ]; then
        RESULT="Backup False leveldb"
      fi
    fi
  done
}

delete_old() {
  TOTAL=$(find ${ROOTFOLDER} -type f | wc -l)
  if [ $TOTAL -gt $BACKUP_AMOUNT ]; then
    echo "delete old data ${ROOTFOLDER}/${DELETE_FILE} " 1>> ${LOG_PATH}/backup.log 2>> ${LOG_PATH}/backup.err.log
    DELETE_FILE=$(ls -1 ${ROOTFOLDER} | head -n 1)
    rm -rf "${ROOTFOLDER}/${DELETE_FILE}"
  fi
}

main() {
  if [ ! -d $LOG_PATH ]; then
    mkdir -p $LOG_PATH
  fi
  if [ ! -d $ROOTFOLDER ]; then
    mkdir -p $ROOTFOLDER
  fi
  echo "$(date +"%Y_%m_%d_%H:%M:%S") ===== start backup leveldb & config!~ =====" 2>&1 | tee -a ${LOG_PATH}/backup.log >> ${LOG_PATH}/backup.err.log

  if [ ! -d $SYNC_FOLDER ]; then
    mkdir $SYNC_FOLDER
  fi

  declare -a list
  # leveldb
  list[0]="bolt1;bolt-currency;${HOME}/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt1;bolt-keychain;${HOME}/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt1;bolt-keystone;${HOME}/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt1;bolt-trust;${HOME}/bolt-trust/MerMer-framework/dataset"
  list[4]="bolt1;bolt-currency-db;${HOME}/BOLT-CURRENCY/db"
  list[5]="bolt1;bolt-keychain-db;${HOME}/BOLT-KEYCHAIN/db"
  list[6]="bolt1;bolt-keystone-db;${HOME}/BOLT-KEYSTONE/db"
  list[7]="bolt1;bolt-keystone-db;${HOME}/BOLT-KEYSTONE/db"
  # env
  list[8]="bolt2;BOLT-CURRENCY.env;${HOME}/BOLT-CURRENCY/env.js"
  list[9]="bolt2;BOLT-KEYCHAIN.env;${HOME}/BOLT-KEYCHAIN/env.js"
  list[10]="bolt2;BOLT-KEYSTONE.env;${HOME}/BOLT-KEYSTONE/env"
  list[11]="bolt2;BOLT-TRUST.env;${HOME}/BOLT-TRUST/env.js"
  list[12]="bolt2;contracts.env;${HOME}/contracts/env.js"
  list[13]="bolt2;gringotts.env;${HOME}/gringotts/env.js"
  # microservice
  list[14]="bolt2;BOLT-CURRENCY.config.toml;${HOME}/BOLT-CURRENCY/sample.config.toml"
  list[15]="bolt2;BOLT-KEYCHAIN.config.toml;${HOME}/BOLT-KEYCHAIN/sample.config.toml"
  list[16]="bolt2;BOLT-KEYSTONE.config.toml;${HOME}/BOLT-KEYSTONE/sample.config.toml"
  list[17]="bolt2;BOLT-TRUST.config.toml;${HOME}/BOLT-TRUST/sample.config.toml"
  # howinvest
  list[18]="apigateway1;howinvest-apigateway;${HOME}/howinvest-apigateway/MerMer-framework/dataset"
  list[19]="howninvest1;howinvest-blacklist;${HOME}/howinvest-blacklist/MerMer-framework/dataset"
  list[20]="howninvest1;howinvest-trademodule;${HOME}/howinvest-trademodule/MerMer-framework/dataset"
  list[21]="howninvest1;howinvest-authmodule;${HOME}/howinvest-authmodule/MerMer-framework/dataset"
  #config
  list[22]="apigateway2;Howinvest-APIGateway.config;${HOME}/Howinvest-APIGateway/private/config.toml"
  list[23]="howninvest2;HowInvest-AuthModule.config;${HOME}/HowInvest-AuthModule/private/config.toml"
  list[24]="howninvest2;HowInvest-TradeModule.config;${HOME}/HowInvest-TradeModule/private/config.toml"
  list[25]="howninvest2;HowInvest-Blacklist.config;${HOME}/HowInvest-Blacklist/private/config.toml"
  sync ${list}

  if [ -d $FOLDER ]; then
    tar -zcvf "${FOLDER}.tar.gz" ${FOLDER}
    rm -rf ${FOLDER}
  fi

  delete_old
  echo "$(date +"%Y_%m_%d_%H:%M:%S") ===== backup leveldb & config finish!~ =====" 2>&1 | tee -a ${LOG_PATH}/backup.log >> ${LOG_PATH}/backup.err.log
  echo $RESULT
}

main "$@"
