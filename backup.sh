#!/bin/bash
SSH_IP=ubuntu@ec2-3-216-50-113.compute-1.amazonaws.com
SSH_KEY_PATH=~/Downloads/BOLTCHAIN.pem
FOLDER="BOLT_"$(date +"%Y_%m_%d_%R")
DBNAME="BOLT_DB_"$(date +"%Y_%m_%d_%R")".tar.gz"
DBPATH="trustDB"

dump() {
  list=$1
  for i in "${list[@]}"
  do
      IFS=";" read -r -a arr <<< "${i}"
      name="${arr[0]}"
      path="${arr[1]}"
      scp -r -i ${SSH_KEY_PATH} ${SSH_IP}:/home/ubuntu/${path} ./${FOLDER}/${name}
  done
}

dump_db() {
  ssh -i ${SSH_KEY_PATH} ${SSH_IP} "tar -zcvf - ${DBNAME} ${DBPATH}" | cat > ./${FOLDER}/${DBNAME}
}

main() {
  mkdir ${FOLDER}

  declare -a list
  # leveldb
  list[0]="bolt-currency;bolt-currency/MerMer-framework/dataset"
  list[1]="bolt-keychain;bolt-keychain/MerMer-framework/dataset"
  list[2]="bolt-keystone;bolt-keystone/MerMer-framework/dataset"
  list[3]="bolt-trust;bolt-trust/MerMer-framework/dataset"
  # microservice
  list[4]="BOLT-CURRENCY.config.toml;BOLT/BOLT-CURRENCY/sample.config.toml"
  list[5]="BOLT-KEYCHAIN.config.toml;BOLT/BOLT-KEYCHAIN/sample.config.toml"
  list[6]="BOLT-KEYSTONE.config.toml;BOLT/BOLT-KEYSTONE/sample.config.toml"
  list[7]="BOLT-TRUST.config.toml;BOLT/BOLT-TRUST/sample.config.toml"
  dump ${list}

  dump_db
}

main "$@"