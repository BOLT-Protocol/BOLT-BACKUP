# BOLT-BACKUP

**執行 recovery 前請先手動備份**

## backup leveldb & config

`backup.sh`

### 相關設定

```
BOLT_SSH_IP: BOLT 主機 ip
HOWINVEST_SSH_IP: HOWINVEST 主機 ip
SSH_KEY_PATH: ssh key
ROOTFOLDER: 要備份的目錄
SYNC_FOLDER: sync 遠端設定檔的目錄
HOME: sync 目標家目錄（配合下方 list）
BACKUP_AMOUNT: 備份份數
```

### 內部 sync() 參數

可自行更改備份目標

```
list[0]="bolt1;bolt-currency;/home/ubuntu/bolt-currency/MerMer-framework/dataset"
"目標分類 ; 目標名稱 ; rsync 目標"
```

### exec:

```
$ sh backup.sh
```

## backup PostgreSQL

`backupDB.sh`

### 相關設定

```
SSH_IP: DB 主機 ip
SSH_KEY_PATH: ssh key
ROOTFOLDER: 要備份的目錄
USER_NAME: DB username
BACKUP_AMOUNT: 備份份數
```

### exec:

```
$ sh backupDB.sh
start backup db!~
please enter db password!
Password: 

please enter db password!
Password: 

receiving incremental file list
bolt_2019_08_07_18.dmp
trust_2019_08_07_18.dmp

sent 3,417 bytes  received 847,787 bytes  567,469.33 bytes/sec
total size is 1,694,586  speedup is 1.99
```

## recovery leveldb & config

**執行 recovery 前請先手動備份**

`recovery.sh`

### 相關設定

```
BOLT_SSH_IP: BOLT 主機 ip
HOWINVEST_SSH_IP: HOWINVEST 主機 ip
SSH_KEY_PATH: ssh key
BACKUP_FOLDER: 備份的目錄
SYNC_FOLDER: sync 遠端設定檔的目錄
HOME: sync 目標家目錄（配合下方 list）
```

### exec:

```
sh recover.sh 復原備份檔案名稱
sh recover.sh BOLT_2019_08_07_17.tar.gz
```

## recovery PostgreSQL

**執行 recovery 前請先手動備份**

`recoveryDB.sh`

### 相關設定

```
SSH_IP: DB 主機 ip
SSH_KEY_PATH: ssh key
ROOTFOLDER: 要備份的目錄
USER_NAME: PostgreSQL username
```

### exec:

```
sh recoverDB.sh "備份檔檔名" "復原 table 名"
sh recoverDB.sh bolt_2019_08_07_16.dmp bolt
sh recoverDB.sh trust_2019_08_07_16.dmp trust
```
