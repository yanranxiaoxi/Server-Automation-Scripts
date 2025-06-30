# Server Automation Scripts

小汐个人服务器自动化维护脚本，适用于 AlmaLinux 8 & AlmaLinux 9 & AlmaLinux 10 及其兼容服务器，所有脚本均需以 root 权限运行

## 容器定制化 / Container

### caddy2

#### 自动同步 Nice Caddyfile 中的复用块 / autoSyncNiceCaddyfile

```shell
wget -O ~/autoSyncNiceCaddyfile.sh https://sh.soraharu.com/Container/caddy2/autoSyncNiceCaddyfile.sh && sh ~/autoSyncNiceCaddyfile.sh "${containerType}" && rm -f ~/autoSyncNiceCaddyfile.sh
```

### gitlab

#### 定时任务 / cron

```shell
wget -O ~/gitlab.cron.sh https://sh.soraharu.com/Container/gitlab/cron.sh && sh ~/gitlab.cron.sh && rm -f ~/gitlab.cron.sh
```

### gitlab-pages

#### 定时任务 / cron

```shell
wget -O ~/gitlab-pages.cron.sh https://sh.soraharu.com/Container/gitlab-pages/cron.sh && sh ~/gitlab-pages.cron.sh && rm -f ~/gitlab-pages.cron.sh
```

### gitlab-runner

#### 定时任务 / cron

```shell
wget -O ~/gitlab-runner.cron.sh https://sh.soraharu.com/Container/gitlab-runner/cron.sh && sh ~/gitlab-runner.cron.sh && rm -f ~/gitlab-runner.cron.sh
```

### image-transfer-station

#### 定时任务 / cron

```shell
wget -O ~/image-transfer-station.cron.sh https://sh.soraharu.com/Container/image-transfer-station/cron.sh && sh ~/image-transfer-station.cron.sh && rm -f ~/image-transfer-station.cron.sh
```

### mastodon

#### 定时任务 / cron

```shell
wget -O ~/mastodon.cron.sh https://sh.soraharu.com/Container/mastodon/cron.sh && sh ~/mastodon.cron.sh && rm -f ~/mastodon.cron.sh
```

### typecho

#### 定时任务 / cron

```shell
wget -O ~/typecho.cron.sh https://sh.soraharu.com/Container/typecho/cron.sh && sh ~/typecho.cron.sh && rm -f ~/typecho.cron.sh
```

## 服务器维护 / ServerMaintenance

### 备份 / Backup

#### 将容器数据备份到 S3 / backupContainerToS3

```shell
wget -O ~/backupContainerToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupContainerToS3.sh && sh ~/backupContainerToS3.sh "${serverName}" "${containerType}" "${s3AccessKey}" "${s3SecretKey}" "${s3ApiAddress}" "${s3BucketName}" "${s3StorageClass}" "firstRun" "${timerTime}" && rm -f ~/backupContainerToS3.sh
```

#### 将 MariaDB 10 数据库备份到 S3 / backupMariaDB10DatabaseToS3

```shell
wget -O ~/backupMariaDB10DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupMariaDB10DatabaseToS3.sh && sh ~/backupMariaDB10DatabaseToS3.sh "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}" && rm -f ~/backupMariaDB10DatabaseToS3.sh
```

#### 将 MariaDB 11 数据库备份到 S3 / backupMariaDB11DatabaseToS3

```shell
wget -O ~/backupMariaDB11DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupMariaDB11DatabaseToS3.sh && sh ~/backupMariaDB11DatabaseToS3.sh "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}" && rm -f ~/backupMariaDB11DatabaseToS3.sh
```

#### 将 PostgreSQL 14 数据库备份到 S3 / backupPostgreSQL14DatabaseToS3

```shell
wget -O ~/backupPostgreSQL14DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL14DatabaseToS3.sh && sh ~/backupPostgreSQL14DatabaseToS3.sh "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}" && rm -f ~/backupPostgreSQL14DatabaseToS3.sh
```

#### 将 PostgreSQL 16 数据库备份到 S3 / backupPostgreSQL16DatabaseToS3

```shell
wget -O ~/backupPostgreSQL16DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL16DatabaseToS3.sh && sh ~/backupPostgreSQL16DatabaseToS3.sh "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}" && rm -f ~/backupPostgreSQL16DatabaseToS3.sh
```

#### 将 PostgreSQL 17 数据库备份到 S3 / backupPostgreSQL17DatabaseToS3

```shell
wget -O ~/backupPostgreSQL17DatabaseToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL17DatabaseToS3.sh && sh ~/backupPostgreSQL17DatabaseToS3.sh "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}" && rm -f ~/backupPostgreSQL17DatabaseToS3.sh
```

### 操作系统初始化配置 / FirstInstallation

#### AlmaLinux 8 + Podman / AlmaLinux8Podman

```shell
wget -O ~/AlmaLinux8Podman.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux8Podman.sh && sh ~/AlmaLinux8Podman.sh "${sshPublicKey}" "${prettyHostname}" "${staticHostname}" && rm -f ~/AlmaLinux8Podman.sh
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语
3. 在 Cockpit 内开启内核补丁

#### AlmaLinux 9 + Podman / AlmaLinux9Podman

```shell
wget -O ~/AlmaLinux9Podman.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux9Podman.sh && sh ~/AlmaLinux9Podman.sh "${sshPublicKey}" "${prettyHostname}" "${staticHostname}" && rm -f ~/AlmaLinux9Podman.sh
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语
3. 在 Cockpit 内开启内核补丁

#### AlmaLinux 10 + Podman / AlmaLinux10Podman

```shell
wget -O ~/AlmaLinux10Podman.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux10Podman.sh && sh ~/AlmaLinux10Podman.sh "${sshPublicKey}" "${prettyHostname}" "${staticHostname}" && rm -f ~/AlmaLinux10Podman.sh
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语
3. 在 Cockpit 内开启内核补丁

#### AlmaLinux 10 + Podman Public Image / AlmaLinux10PodmanPublicImage

```shell
wget -O ~/AlmaLinux10PodmanPublicImage.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux10PodmanPublicImage.sh && sh ~/AlmaLinux10PodmanPublicImage.sh && rm -f ~/AlmaLinux10PodmanPublicImage.sh
```

脚本执行完成后续执行：

1. 使用 `history -c` 清除历史记录

### Podman 容器管理 / Podman

#### 禁用自动升级定时器 / disableAutoUpdateTimer

```shell
wget -O ~/disableAutoUpdateTimer.sh https://sh.soraharu.com/ServerMaintenance/Podman/disableAutoUpdateTimer.sh && sh ~/disableAutoUpdateTimer.sh && rm -f ~/disableAutoUpdateTimer.sh
```

#### 启用新容器的自动升级 / newAutoUpdateContainer

```shell
wget -O ~/newAutoUpdateContainer.sh https://sh.soraharu.com/ServerMaintenance/Podman/newAutoUpdateContainer.sh && sh ~/newAutoUpdateContainer.sh "${containerName}" && rm -f ~/newAutoUpdateContainer.sh
```

#### 移除已配置自动升级的容器 / removeAutoUpdateContainer

```shell
wget -O ~/removeAutoUpdateContainer.sh https://sh.soraharu.com/ServerMaintenance/Podman/removeAutoUpdateContainer.sh && sh ~/removeAutoUpdateContainer.sh "${containerName}" && rm -f ~/removeAutoUpdateContainer.sh
```

### Swap 管理 / Swap

#### 新建 Swap / newSwap

```shell
wget -O ~/newSwap.sh https://sh.soraharu.com/ServerMaintenance/Swap/newSwap.sh && sh ~/newSwap.sh "${swapSize}" "/swapfile" && rm -f ~/newSwap.sh
```

#### 调整 Swap 大小 / resizeSwap

```shell
wget -O ~/resizeSwap.sh https://sh.soraharu.com/ServerMaintenance/Swap/resizeSwap.sh && sh ~/resizeSwap.sh "${swapSize}" "/swapfile" && rm -f ~/resizeSwap.sh
```

#### 移除 Swap / removeSwap

```shell
wget -O ~/removeSwap.sh https://sh.soraharu.com/ServerMaintenance/Swap/removeSwap.sh && sh ~/removeSwap.sh "/swapfile" && rm -f ~/removeSwap.sh
```
