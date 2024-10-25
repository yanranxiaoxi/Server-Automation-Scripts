#!/bin/bash

# Backup - backupContainerToS3
#
# 将容器数据备份到 S3 存储桶
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# 服务器名称（对应 S3 中的路径）
serverName=$1
# 容器类型，'podman' 或是 'docker'
containerType=$2
# S3 Access Key
s3AccessKey=$3
# S3 Secret Key
s3SecretKey=$4
# S3 API 地址
s3ApiAddress=$5
# S3 桶名称
s3BucketName=$6
# S3 存储类
s3StorageClass=$7
# 是否首次安装，是则填写 'firstRun'，将会自动注册到 crontab
firstRun=$8
# 定时任务执行时刻
timer=$9

# 检查变量
if [[ -z "${serverName}" || -z "${containerType}" || -z "${s3AccessKey}" || -z "${s3SecretKey}" || -z "${s3ApiAddress}" ]]; then
	echo "错误：输入变量不正确"
	exit
fi
if [[ -z "${timer}" ]]; then
		timer="0 3 * * *"
	fi
if [[ -z "${s3BucketName}" ]]; then
	s3BucketName="backup-container"
fi
if [[ -z "${s3StorageClass}" ]]; then
	s3StorageClass="Standard"
	# s3StorageClass="DeepColdArchive"
fi

# 新建备份目录
mkdir -p /"${containerType}"directorybackup/

# 自动生成归档路径信息
backupDate=$(date "+%Y%m%d%H%M%S")
backupDay=$(date "+%Y%m%d")
backupFolders=$(ls /"${containerType}"directory/)

# 使用 tar 压缩待备份文件
mkdir -p /"${containerType}"directorybackup/"${backupDay}"/
cd /"${containerType}"directory/ || exit
for folderName in ${backupFolders}; do
	tar zcvf /"${containerType}"directorybackup/"${backupDay}"/backup_"${folderName}"_"${backupDate}".tar.gz "${folderName}"/
done

# 识别系统架构并下载 MinIO Client
if [ ! -f "/${containerType}directorybackup/mc" ]; then
	cpuArch=$(arch)
	if [[ ${cpuArch} =~ "x86_64" ]]; then
		mcDownloadUrl="https://dl.min.io/client/mc/release/linux-amd64/mc"
	elif [[ ${cpuArch} =~ "aarch64" ]]; then
		mcDownloadUrl="https://dl.min.io/client/mc/release/linux-arm64/mc"
	elif [[ ${cpuArch} =~ "ppc64le" ]]; then
		mcDownloadUrl="https://dl.min.io/client/mc/release/linux-ppc64le/mc"
	else
		echo "Fatal error: unsupport CPU arch!"
		exit
	fi
	curl "${mcDownloadUrl}" --create-dirs -o /"${containerType}"directorybackup/mc
	chmod +x /"${containerType}"directorybackup/mc
fi

# 使用 MinIO Client 将数据上传到 S3 服务器
cd /"${containerType}"directorybackup/ || exit
./mc alias set "${serverName}" "${s3ApiAddress}" "${s3AccessKey}" "${s3SecretKey}"
./mc cp --recursive --storage-class=${s3StorageClass} /"${containerType}"directorybackup/"${backupDay}"/ "${serverName}"/${s3BucketName}/"${serverName}"/"${backupDay}"/

# 清理文件
find . -type d | sed -n '2,$p' | xargs rm -rf

# 创建系统定时任务
if [[ ${firstRun} =~ "firstRun" ]]; then
	cron="${timer} root wget -O ~/backupContainerToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupContainerToS3.sh && sh ~/backupContainerToS3.sh ${serverName} ${containerType} ${s3AccessKey} ${s3SecretKey} ${s3ApiAddress} ${s3BucketName} ${s3StorageClass} && rm -f ~/backupContainerToS3.sh"
	# sed -i -e $'$a\\\n'"${cron}" /etc/crontab
	echo ${cron} >>/etc/crontab
	systemctl restart crond
fi
