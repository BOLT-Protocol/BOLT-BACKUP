#!/bin/bash
BOLT_SSH_IP=172.26.13.218
APIGATEWAY_SSH_IP=172.26.6.233
HOWINVEST_SSH_IP=172.26.8.110
SSH_KEY_PATH=~/.ssh/id_rsa
BACKUP_FOLDER="Backup"
SYNC_FOLDER="BOLT_BACKUP"
HOME="/home/tideops"

sync() {
  list=$1
  for i in "${list[@]}"
  do
    IFS=";" read -r -a arr <<< "${i}"
    plateform="${arr[0]}"
    name="${arr[1]}"
    path="${arr[2]}"
    echo "\e[0;32rsync ${name} data\e[0m"
    if [ $plateform == "bolt" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" ./${SYNC_FOLDER}/${name}/dataset/* ${BOLT_SSH_IP}:${path} 
    elif [ $plateform == "howninvest" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" ./${SYNC_FOLDER}/${name}/dataset/* ${HOWINVEST_SSH_IP}:${path} 
    elif [ $plateform == "apigateway" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" ./${SYNC_FOLDER}/${name}/dataset/* ${APIGATEWAY_SSH_IP}:${path} 
    fi
  done
}

main() {
  echo "\e[0;32mstart recovery!~ \e[0m"
  if [ -z $1 ]; then
    echo "\e[0;31mrequire recovery file!!\e[0m"
    return
  fi

  echo "\e[0;32unzip backup file!~ \e[0m"
  tar -zxvf "${BACKUP_FOLDER}/$1"

  ZIPFILE_NAME=$(echo $1 | sed s/.tar.gz//g)

  cp -rf ${BACKUP_FOLDER}/$ZIPFILE_NAME/* $SYNC_FOLDER/

  declare -a list
  # leveldb
  list[0]="bolt;bolt-currency;${HOME}/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt;bolt-keychain;${HOME}/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt;bolt-keystone;${HOME}/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt;bolt-trust;${HOME}/bolt-trust/MerMer-framework/dataset"
  # microservice
  list[4]="bolt;BOLT-CURRENCY.config.toml;${HOME}/BOLT/BOLT-CURRENCY/sample.config.toml"
  list[5]="bolt;BOLT-KEYCHAIN.config.toml;${HOME}/BOLT/BOLT-KEYCHAIN/sample.config.toml"
  list[6]="bolt;BOLT-KEYSTONE.config.toml;${HOME}/BOLT/BOLT-KEYSTONE/sample.config.toml"
  list[7]="bolt;BOLT-TRUST.config.toml;${HOME}/BOLT/BOLT-TRUST/sample.config.toml"
  # howinvest
  list[8]="howninvest;howinvest-receptiondesk;${HOME}/howinvest-receptiondesk/MerMer-framework/dataset"
  list[9]="apigateway;howinvestmockapi;${HOME}/howinvestmockapi/MerMer-framework/dataset"
  #list[10]="howninvest;OrderEngine;${HOME}/OrderEngine"
  sync ${list}

  rm -rf ${BACKUP_FOLDER}/$ZIPFILE_NAME
}

main "$@"
