#!/bin/bash
BOLT_SSH_IP=ubuntu@ec2-3-216-50-113.compute-1.amazonaws.com
HOWINVEST_SSH_IP=ubuntu@ec2-3-216-89-157.compute-1.amazonaws.com
SSH_KEY_PATH=~/Downloads/BOLTCHAIN.pem
ROOTFOLDER="Backup"
FOLDER="${ROOTFOLDER}/BOLT_"$(date +"%Y_%m_%d_%H")
SYNC_FOLDER="BOLT_BACKUP"
BACKUP_AMOUNT="300"
HOME="/home/ubuntu"

sync() {
  list=$1
  for i in "${list[@]}"
  do
    IFS=";" read -r -a arr <<< "${i}"
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
  list[0]="bolt1;bolt-currency;/home/ubuntu/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt1;bolt-keychain;/home/ubuntu/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt1;bolt-keystone;/home/ubuntu/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt1;bolt-trust;/home/ubuntu/bolt-trust/MerMer-framework/dataset"
  # microservice
  list[4]="bolt2;BOLT-CURRENCY.config.toml;/home/ubuntu/BOLT/BOLT-CURRENCY/sample.config.toml"
  list[5]="bolt2;BOLT-KEYCHAIN.config.toml;/home/ubuntu/BOLT/BOLT-KEYCHAIN/sample.config.toml"
  list[6]="bolt2;BOLT-KEYSTONE.config.toml;/home/ubuntu/BOLT/BOLT-KEYSTONE/sample.config.toml"
  list[7]="bolt2;BOLT-TRUST.config.toml;/home/ubuntu/BOLT/BOLT-TRUST/sample.config.toml"
  # howinvest
  list[8]="howninvest;howinvest-receptiondesk;/home/ubuntu/howinvest-receptiondesk/MerMer-framework/dataset"
  list[9]="howninvest;howinvestmockapi;/home/ubuntu/howinvestmockapi/MerMer-framework/dataset"
  list[10]="howninvest;OrderEngine;/home/ubuntu/OrderEngine/"
  sync ${list}

  if [ -d $FOLDER ]; then
    tar -zcvf "${FOLDER}.tar.gz" ${FOLDER}
    rm -rf ${FOLDER}
  fi

  delete_old
}

main "$@"