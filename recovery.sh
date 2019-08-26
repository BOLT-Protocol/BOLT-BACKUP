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
    from="${arr[1]}"
    to="${arr[2]}"
    echo "rsync ${from} data"
    if [ $plateform == "bolt1" ]; then
      rsync -av ${SYNC_FOLDER}/${from} ${BOLT_SSH_IP}:${to}
    elif [ $plateform == "bolt2" ]; then
      rsync -v ${SYNC_FOLDER}/${from} ${BOLT_SSH_IP}:${to}
    elif [ $plateform == "howninvest1" ]; then
      rsync -av ${SYNC_FOLDER}/${from} ${HOWINVEST_SSH_IP}:${to}
    elif [ $plateform == "howninvest2" ]; then
      rsync -v ${SYNC_FOLDER}/${from} ${HOWINVEST_SSH_IP}:${to}
    elif [ $plateform == "apigateway1" ]; then
      rsync -av ${SYNC_FOLDER}/${from} ${APIGATEWAY_SSH_IP}:${to}
    elif [ $plateform == "apigateway2" ]; then
      rsync -v ${SYNC_FOLDER}/${from} ${APIGATEWAY_SSH_IP}:${to}
    fi
  done
}

recoveryBOLT() {
  echo "recoveryBOLT!!"
  declare -a list
  # leveldb
  list[0]="bolt1;bolt-currency/dataset/*;${HOME}/bolt-currency/MerMer-framework/dataset"
  list[1]="bolt1;bolt-keychain/dataset/*;${HOME}/bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt1;bolt-keystone/dataset/*;${HOME}/bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt1;bolt-trust/dataset/*;${HOME}/bolt-trust/MerMer-framework/dataset"
  list[4]="bolt1;bolt-currency-db/db/*;${HOME}/BOLT-CURRENCY/db"
  list[5]="bolt1;bolt-keychain-db/db/*;${HOME}/BOLT-KEYCHAIN/db"
  list[6]="bolt1;bolt-keystone-db/db/*;${HOME}/BOLT-KEYSTONE/db"
  list[7]="bolt1;bolt-keystone-db/db/*;${HOME}/BOLT-KEYSTONE/db"
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
  sync ${list}
}

recoveryHowninvest() {
  echo "recoveryHowninvest!!"
  declare -a list
  list[0]="howninvest1;howinvest-blacklist/dataset/*;${HOME}/howinvest-blacklist/bolt-BlackList/dataset"
  list[1]="howninvest1;howinvest-trademodule/dataset/*;${HOME}/howinvest-trademodule/MerMer-framework/dataset"
  list[2]="howninvest1;howinvestauthmodule/dataset/*;${HOME}/howinvestauthmodule/MerMer-framework/dataset"
  list[3]="howninvest2;HowInvest-AuthModule.config;${HOME}/HowInvest-AuthModule/private/config.toml"
  list[4]="howninvest2;HowInvest-TradeModule.config;${HOME}/HowInvest-TradeModule/private/config.toml"
  list[5]="howninvest2;HowInvest-Blacklist.config;${HOME}/HowInvest-Blacklist/private/config.toml"
  sync ${list}
}

recoveryAPIGateway() {
  echo "recoveryAPIGateway!!"
  declare -a list
  # howinvest
  list[0]="apigateway1;howinvestapigateway/dataset/*;${HOME}/howinvestapigateway/MerMer-framework/dataset"
  list[1]="apigateway2;Howinvest-APIGateway.config;${HOME}/Howinvest-APIGateway/private/config.toml"
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
  
  ## 因為壓縮後會是 ROOTFOLDER 最上層 extra_data，所以這便要改成 extra_data
  rm -rf extra_data
}

main "$@"
