# BOLT-BACKUP

**執行 recovery 前請先手動備份**

## 前置作業

建立 ssh key，並推到 BOLT_SSH_IP、APIGATEWAY_SSH_IP、HOWINVEST_SSH_IP 位置

```
$ mkdir -p ~/.ssh
$ chmod 700 ~/.ssh
$ ssh-keygen
$ ssh-copy-id USER@HOST
```

## backup leveldb & config

`backup.sh`

### 相關設定

```
BOLT_SSH_IP: BOLT 主機 ip
APIGATEWAY_SSH_IP: APIGataway 主機 ip
HOWINVEST_SSH_IP: HOWINVEST 主機 ip
SSH_KEY_PATH: ssh key
HOME: sync 目標家目錄（配合下方 list）
ROOTFOLDER: 要備份的目錄(增量備份的存檔)
SYNC_FOLDER: 要備份的目錄(完全 sync)
BACKUP_AMOUNT: 備份份數
LOG_PATH: log 存放位置
```

### exec:

```
$ bash backup.sh
```

## backup PostgreSQL

`backupDB.sh`

### 相關設定

```
SSH_IP: DB 主機 ip
SSH_KEY_PATH: ssh key
ROOTFOLDER: 要備份的目錄
USER_NAME: DB username
USER_PASSWORD: DB password
BACKUP_AMOUNT: 備份份數
LOG_PATH: log 存放位置
```

### exec:

```
$ bash backupDB.sh
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
APIGATEWAY_SSH_IP: APIGataway 主機 ip
HOWINVEST_SSH_IP: HOWINVEST 主機 ip
HOME: sync 目標家目錄（配合下方 list）
BACKUP_FOLDER: 備份的目錄
SYNC_FOLDER: sync 遠端設定檔的目錄
```

並修改下面 95, 102 行

```
# 解壓縮完會是 extra_data/Backup 原因在於 backup 時，是對 ROOTFOLDER 做壓縮，而預設 ROOTFOLDER 為 /extra_data/Backup
cp -rf extra_data/Backup/$ZIPFILE_NAME/* $SYNC_FOLDER/


## 因為壓縮後會是 ROOTFOLDER 最上層 extra_data，所以這便要改成 extra_data
rm -rf extra_data
```

### exec:

先於 BACKUP_FOLDER 尋找要還原檔案

···
$ ls Backup
BOLT_2019_08_07_17.tar.gz
BOLT_2019_08_07_18.tar.gz
BOLT_2019_08_07_20.tar.gz
···

執行還原

```
bash recover.sh 復原備份檔案名稱
bash recover.sh BOLT_2019_08_07_17.tar.gz
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

先於 BACKUP_FOLDER 尋找要還原檔案

···
$ ls BackupDB
bolt_2019_08_06_16.dmp
bolt_2019_08_07_16.dmp
trust_2019_08_06_16.dmp
trust_2019_08_07_16.dmp
···

執行還原

```
bash recoverDB.sh "備份檔檔名" "復原 table 名"
bash recoverDB.sh bolt_2019_08_07_16.dmp bolt
bash recoverDB.sh trust_2019_08_07_16.dmp trust
```

## Crontab

```
// 編輯 crontab
crontab -e
```

將下面設定檔貼上後存擋

```
0 * * * * bash /home/tideops/BOLT-BACKUP/backup.sh
0 0 * * * bash /home/tideops/BOLT-BACKUP/backupDB.sh
```

```
// 顯示 crontab 列表
crontab -l
```