#!/bin/bash
BOLT_SSH_IP=172.26.13.218
APIGATEWAY_SSH_IP=172.26.6.233
HOWINVEST_SSH_IP=172.26.8.110
SSH_KEY_PATH=~/.ssh/id_rsa
ROOTFOLDER="Backup"
FOLDER="${ROOTFOLDER}/BOLT_"$(date +"%Y_%m_%d_%H")
SYNC_FOLDER="BOLT_BACKUP"
BACKUP_AMOUNT="300"
HOME="/home/tideops"

sync() {
  list=$1
  IFS=";"
  for i in "${list[@]}"
  do
    read -a arr <<< "${i}"
    plateform="${arr[0]}"
    name="${arr[1]}"
    path="${arr[2]}"
    # echo "\e[0;32rsync ${name} data\e[0m"
    if [ $plateform == "bolt1" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER/${name}  ${BOLT_SSH_IP}:${path} ./${SYNC_FOLDER}/${name}
    elif [ $plateform == "bolt2" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER/  ${BOLT_SSH_IP}:${path} ./${SYNC_FOLDER}/${name}
    elif [ $plateform == "howninvest" ] && [ $name == "OrderEngine" ]; then
      mkdir -p "${SYNC_FOLDER}/OrderEngine/dataset"
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER/${name}  ${HOWINVEST_SSH_IP}:${path}/* ./${SYNC_FOLDER}/${name}/dataset
    elif [ $plateform == "howninvest" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER/${name}  ${HOWINVEST_SSH_IP}:${path} ./${SYNC_FOLDER}/${name}
    elif [ $plateform == "apigateway" ]; then
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER/${name}  ${APIGATEWAY_SSH_IP}:${path} ./${SYNC_FOLDER}/${name}
    fi
  done
}

delete_old() {
  TOTAL=$(find ${ROOTFOLDER} -type f | wc -l)
  if [ $TOTAL -gt $BACKUP_AMOUNT ]; then
    echo "\e[0;32delete old data ${ROOTFOLDER}/${DELETE_FILE} \e[0m"
    DELETE_FILE=$(ls -1 ${ROOTFOLDER} | head -n 1)
    rm -rf "${ROOTFOLDER}/${DELETE_FILE}"
  fi
}

main() {
  if [ ! -d $SYNC_FOLDER ]; then
    mkdir $SYNC_FOLDER
  fi

  declare -a list
  # leveldb
  list[0]="bolt1;bolt-currency;${HOME}/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt1;bolt-keychain;${HOME}/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt1;bolt-keystone;${HOME}/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt1;bolt-trust;${HOME}/bolt-trust/MerMer-framework/dataset"
  # microservice
  list[4]="bolt2;BOLT-CURRENCY.config.toml;${HOME}/BOLT-CURRENCY/sample.config.toml"
  list[5]="bolt2;BOLT-KEYCHAIN.config.toml;${HOME}/BOLT-KEYCHAIN/sample.config.toml"
  list[6]="bolt2;BOLT-KEYSTONE.config.toml;${HOME}/BOLT-KEYSTONE/sample.config.toml"
  list[7]="bolt2;BOLT-TRUST.config.toml;${HOME}/BOLT-TRUST/sample.config.toml"
  # howinvest
  list[9]="apigateway;howinvestmockapi;${HOME}/howinvestmockapi/MerMer-framework/dataset"
  list[8]="howninvest;howinvest-receptiondesk;${HOME}/howinvest-receptiondesk/MerMer-framework/dataset"
  sync ${list}

  if [ -d $FOLDER ]; then
    tar -zcvf "${FOLDER}.tar.gz" ${FOLDER}
    rm -rf ${FOLDER}
  fi

  delete_old
}

main "$@"
