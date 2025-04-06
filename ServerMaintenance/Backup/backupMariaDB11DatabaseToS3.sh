#!/bin/bash

# Backup - backupMariaDB11DatabaseToS3
#
# 将 MariaDB 11 数据库备份到 S3 存储桶
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 本脚本只支持 Podman 容器环境
# 需要首先启用 backupContainerToS3.sh 脚本

# 服务器名称（对应 S3 中的路径）
serverName=$1
# 容器名称
containerName=$2
# 数据库用户名（可以为空）
databaseUser=$3
# 数据库密码（可以为空）
databasePassword=$4
# S3 桶名称
s3BucketName=$5
# S3 存储类
s3StorageClass=$6
# 是否首次安装，是则填写 'firstRun'，将会自动注册到 crontab
firstRun=$7
# 定时任务执行时刻
timerTime=$8

# 检查变量
if [[ -z "${serverName}" ]]; then
	echo "错误：输入变量不正确"
	exit
fi
if [[ -z "${containerName}" ]]; then
	containerName='mariadb11'
fi
if [[ -z "${databaseUser}" ]]; then
	databaseUser='root'
fi
if [[ -z "${s3BucketName}" ]]; then
	s3BucketName="backup-database"
fi
if [[ -z "${s3StorageClass}" ]]; then
	s3StorageClass="Standard"
fi
if [[ -z "${timerTime}" ]]; then
	timerTime='15 4 * * *'
fi

# 检查环境
if [ ! -f "/podmandirectorybackup/mc" ]; then
	echo "错误：请先配置服务器容器备份"
	exit
fi

# 自动生成归档时间信息
backupDate=$(date "+%Y%m%d%H%M%S")
backupDay=$(date "+%Y%m%d")

# 建立备份
if [[ -z "${databasePassword}" ]]; then
	podman exec -t "${containerName}" mariadb-dump --all-databases > /backup/all_databases.sql
else
	podman exec -t "${containerName}" mariadb-dump -u"${databaseUser}" -p"${databasePassword}" --all-databases > /backup/all_databases.sql
fi

# 使用 tar 压缩待备份文件
mkdir -p /databasebackup/upload/
tar zcvf /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz /databasebackup/"${containerName}"/all_databases.sql

# 使用 MinIO Client 将数据上传到 S3 服务器
# /podmandirectorybackup/mc alias set "${serverName}" "${s3ApiAddress}" "${s3AccessKey}" "${s3SecretKey}"
/podmandirectorybackup/mc cp --storage-class="${s3StorageClass}" /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz "${serverName}"/"${s3BucketName}"/"${serverName}"/"${backupDay}"/

# 清理文件
rm -f /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz
rm -f /databasebackup/"${containerName}"/all_databases.sql

# 创建系统定时任务
if [[ ${firstRun} =~ "firstRun" ]]; then
	echo "${timerTime} root wget -O ~/backupMariaDB11DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupMariaDB11DatabaseToS3.sh && sh ~/backupMariaDB11DatabaseToS3.sh ${serverName} ${containerName} ${databaseUser} ${databasePassword} ${s3BucketName} ${s3StorageClass} && rm -f ~/backupMariaDB11DatabaseToS3.sh" >/etc/cron.d/backupMariaDB11DatabaseToS3.cron
	systemctl restart crond
fi
