#!/bin/bash
BOLT_SSH_IP=172.26.13.218
APIGATEWAY_SSH_IP=172.26.0.201
HOWINVEST_SSH_IP=172.26.8.110
HOME="/home/tideops"
BACKUP_FOLDER="/extra_data/Backup"
SYNC_FOLDER="/extra_data/BOLT_SYNC_FOLDER"

sync() {
  list=$1
  for i in "${list[@]}"
  do
    IFS=";" read -r -a arr <<< "${i}"
    plateform="${arr[0]}"
    name="${arr[1]}"
    path="${arr[2]}"
    echo "rsync ${name} data"
    if [ $plateform == "bolt" ]; then
      rsync -av ${SYNC_FOLDER}/${name}/dataset/* ${BOLT_SSH_IP}:${path} 
    elif [ $plateform == "howninvest" ]; then
      rsync -av ${SYNC_FOLDER}/${name}/dataset/* ${HOWINVEST_SSH_IP}:${path} 
    elif [ $plateform == "apigateway" ]; then
      rsync -av ${SYNC_FOLDER}/${name}/dataset/* ${APIGATEWAY_SSH_IP}:${path} 
    fi
  done
}

recoveryBOLT() {
  echo "recoveryBOLT!!"
  declare -a list
  # leveldb
  list[0]="bolt;bolt-currency;${HOME}/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt;bolt-keychain;${HOME}/bolt-keychain/MerMer-framework/dataset"
  list[0]="bolt;bolt-keystone;${HOME}/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt;bolt-trust;${HOME}/bolt-trust/MerMer-framework/dataset"
  # microservice config
  # list[4]="bolt;BOLT-CURRENCY.config.toml;${HOME}/BOLT/BOLT-CURRENCY/sample.config.toml"
  # list[5]="bolt;BOLT-KEYCHAIN.config.toml;${HOME}/BOLT/BOLT-KEYCHAIN/sample.config.toml"
  # list[6]="bolt;BOLT-KEYSTONE.config.toml;${HOME}/BOLT/BOLT-KEYSTONE/sample.config.toml"
  # list[7]="bolt;BOLT-TRUST.config.toml;${HOME}/BOLT/BOLT-TRUST/sample.config.toml"
  sync ${list}
}

recoveryHowninvest() {
  echo "recoveryHowninvest!!"
  declare -a list
  list[0]="howninvest;howinvest-blacklist;${HOME}/howinvest-blacklist/bolt-BlackList/dataset"
  list[1]="howninvest;howinvest-trademodule;${HOME}/howinvest-trademodule/MerMer-framework/dataset"
  list[2]="howninvest;howinvestauthmodule;${HOME}/howinvestauthmodule/MerMer-framework/dataset"
  sync ${list}
}

recoveryAPIGateway() {
  echo "recoveryAPIGateway!!"
  declare -a list
  # howinvest
  list[0]="apigateway;howinvestapigateway;${HOME}/howinvestapigateway/MerMer-framework/dataset"
  sync ${list}
}

main() {
  echo "start recovery!~ "
  if [ -z $1 ]; then
    echo "require recovery file!!"
    return
  fi

  echo "unzip backup file!~ "
  tar -zxvf "${BACKUP_FOLDER}/$1"

  ZIPFILE_NAME=$(echo $1 | sed s/.tar.gz//g)

  # 解壓縮完會是 extra_data/Backup 原因在於 backup 時，是對 ROOTFOLDER 做壓縮，而預設 ROOTFOLDER 為 /extra_data/Backup
  cp -rf extra_data/Backup/$ZIPFILE_NAME/* $SYNC_FOLDER/

  recoveryBOLT
  recoveryHowninvest
  recoveryAPIGateway

  rm -rf extra_data/Backup
}

main "$@"
