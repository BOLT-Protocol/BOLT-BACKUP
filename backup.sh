#!/bin/bash
SSH_IP=ubuntu@ec2-3-216-50-113.compute-1.amazonaws.com
SSH_KEY_PATH=~/Downloads/BOLTCHAIN.pem
ROOTFOLDER="Backup"
FOLDER="${ROOTFOLDER}/BOLT_"$(date +"%Y_%m_%d_%H")
SYNC_FOLDER="BOLT_BACKUP"
# LAST_FOLDER_RAW=$(ls backup| tail -n 1 )
# LAST_FOLDER=$(echo $LAST_FOLDER_RAW | sed -e "s/.tar.gz//")
# TAR_FOLDER_RAW=$(ls backup| tail -n 2 | sed -n 1p)
# TAR_FOLDER=$(echo $TAR_FOLDER_RAW | sed -e "s/.tar.gz//")
DBNAME="BOLT_DB_"$(date +"%Y_%m_%d_%H")".tar.gz"
DBPATH="trustDB"
BACKUP_AMOUNT="4"


dump() {
  list=$1
  for i in "${list[@]}"
  do
      IFS=";" read -r -a arr <<< "${i}"
      name="${arr[0]}"
      path="${arr[1]}"
      rsync -av -e "ssh -i ${SSH_KEY_PATH}" --delete --backup --backup-dir=$(pwd)/$FOLDER  ${SSH_IP}:${path} ./${SYNC_FOLDER}/${name}
  done
}

dump_db() {
  ssh -i ${SSH_KEY_PATH} ${SSH_IP} "tar -zcvf ${DBNAME} ${DBPATH}" | cat > ./${SYNC_FOLDER}/${DBNAME}
}

delete_old() {
  TOTAL=$(find ${ROOTFOLDER} -type f | wc -l)
  if [ $TOTAL -gt $BACKUP_AMOUNT ]; then
    DELETE_FILE=$(ls -1 ${ROOTFOLDER} | head -n 1)
    echo "TOTAL $TOTAL delete $DELETE_FILE"
    rm -rf "${ROOTFOLDER}/$DELETE_FILE"
  fi
}

main() {
  if [ "${ROOTFOLDER}/${LAST_FOLDER}" == ${FOLDER} ]; then
    # same files
    return 1
  fi

  if [ ! -d $SYNC_FOLDER ]; then
    mkdir $SYNC_FOLDER
  fi

  declare -a list
  # leveldb
  list[0]="bolt-currency;/home/ubuntu/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt-keychain;/home/ubuntu/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt-keystone;/home/ubuntu/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt-trust;/home/ubuntu/bolt-trust/MerMer-framework/dataset"
  # microservice
  list[4]="BOLT-CURRENCY.config.toml;/home/ubuntu/BOLT/BOLT-CURRENCY/sample.config.toml"
  list[5]="BOLT-KEYCHAIN.config.toml;/home/ubuntu/BOLT/BOLT-KEYCHAIN/sample.config.toml"
  list[6]="BOLT-KEYSTONE.config.toml;/home/ubuntu/BOLT/BOLT-KEYSTONE/sample.config.toml"
  list[7]="BOLT-TRUST.config.toml;/home/ubuntu/BOLT/BOLT-TRUST/sample.config.toml"
  dump ${list}

  dump_db

  tar -zcvf "${FOLDER}.tar.gz" ${FOLDER}
  rm -rf ${FOLDER}

  delete_old
}

main "$@"