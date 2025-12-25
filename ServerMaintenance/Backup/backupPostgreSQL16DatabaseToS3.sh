#!/bin/bash

# Backup - backupPostgreSQL16DatabaseToS3
#
# 将 PostgreSQL 16 数据库备份到 S3 存储桶
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 本脚本只支持 Podman 容器环境
# 需要首先启用 backupContainerToS3.sh 脚本
# PostgreSQL 本地登录豁免，密码输入暂不支持，欢迎提交 PR

# 服务器名称（对应 S3 中的路径）
serverName=$1
# 容器名称
containerName=${2:-postgres16}
# 数据库用户名
databaseUser=${3:-postgres}
# 数据库密码（可以为空）
databasePassword=$4
# S3 桶名称
s3BucketName=${5:-backup-database}
# S3 存储类
s3StorageClass=${6:-Standard}
# 定时任务执行时刻
timerTime=${7:-"35 4 * * *"}

# 检查变量
if [[ -z "${serverName}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 检查环境
if [ ! -f "/podmandirectorybackup/mc" ]; then
	echo "错误：请先配置服务器容器备份"
	exit 1
fi

# 自动生成归档时间信息
backupDate=$(date "+%Y%m%d%H%M%S")
backupDay=$(date "+%Y%m%d")

# 建立备份
mkdir -p /databasebackup/"${containerName}"/
if [[ -z "${databasePassword}" ]]; then
	podman exec -t "${containerName}" pg_dumpall -U "${databaseUser}" > /databasebackup/"${containerName}"/all_databases.out
else
	podman exec -t "${containerName}" pg_dumpall -U "${databaseUser}" > /databasebackup/"${containerName}"/all_databases.out
fi

# 使用 tar 压缩待备份文件
cd /databasebackup/"${containerName}"/ || exit
if [ ! -f "all_databases.out" ]; then
	echo "错误：待备份数据库文件不存在"
	exit 1
fi
mkdir -p /databasebackup/upload/
tar -zcvf /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz all_databases.out

# 使用 MinIO Client 将数据上传到 S3 服务器
/podmandirectorybackup/mc cp --storage-class="${s3StorageClass}" /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz "${serverName}"/"${s3BucketName}"/"${serverName}"/"${backupDay}"/

# 清理文件
rm -f /databasebackup/upload/backup_"${containerName}"_all_databases_"${backupDate}".tar.gz
rm -f /databasebackup/"${containerName}"/all_databases.out

# 创建系统定时任务
echo "${timerTime} root curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL16DatabaseToS3.sh | bash -s -- \"${serverName}\" \"${containerName}\" \"${databaseUser}\" \"${databasePassword}\" \"${s3BucketName}\" \"${s3StorageClass}\" \"${timerTime}\"" >/etc/cron.d/backupPostgreSQL16DatabaseToS3."${containerName}".cron
systemctl restart crond
