const express = require('express')
const app = express()
const port = 3000

app.get('/', async (req, res) => {
  const levelDB = await execShellCommand('bash backup.sh')
  const DB = await execShellCommand('bash backupDB.sh')
  console.log('DB', DB)
  res.send({ "levelDBBackup": levelDB.includes("Backup Success"), "DBBackup": DB.includes("Backup Success") })
})

function execShellCommand(cmd) {
 const exec = require('child_process').exec;
 return new Promise((resolve, reject) => {
  exec(cmd, (error, stdout, stderr) => {
   if (error) {
    console.warn(error);
   }
   resolve(stdout? stdout : stderr);
  });
 });
}

app.listen(port, () => console.log(`Backup server start: http://127.0.0.1:${port}`))
