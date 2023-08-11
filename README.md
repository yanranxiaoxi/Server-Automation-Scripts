# Server Automation Scripts

小汐个人服务器自动化维护脚本，适用于 AlmaLinux 8 & AlmaLinux 9 及其兼容服务器，所有脚本均需以 root 权限运行

## 容器定制化 / Container

### caddy2

#### 自动同步 Nice Caddyfile 中的复用块 / autoSyncNiceCaddyfile

```shell
wget -O ~/autoSyncNiceCaddyfile.sh https://sh.soraharu.com/Container/caddy2/autoSyncNiceCaddyfile.sh && sh ~/autoSyncNiceCaddyfile.sh "${containerType}" "firstRun" && rm -f ~/autoSyncNiceCaddyfile.sh
```

## 服务器维护 / ServerMaintenance

### 备份 / Backup

#### 将容器目录备份到 S3 / backupContainerToS3

```shell
wget -O ~/backupContainerToS3.sh https://sh.soraharu.com/ServerMaintenance/Backup/backupContainerToS3.sh && sh ~/backupContainerToS3.sh "${serverName}" "${containerType}" "${s3AccessKey}" "${s3SecretKey}" "${s3ApiAddress}" "firstRun" "${timerH}" "${timerM}" && rm -f ~/backupContainerToS3.sh
```

### 操作系统初始化配置 / FirstInstallation

#### AlmaLinux 8 + Podman / AlmaLinux8Podman

```shell
wget -O ~/AlmaLinux8Podman.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux8Podman.sh && sh ~/AlmaLinux8Podman.sh "${sshPublicKey}" "${prettyHostname}" "${staticHostName}" && rm -f ~/AlmaLinux8Podman.sh
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 在 Cockpit 设置语言为 中文（简体）

#### AlmaLinux 9 + Podman / AlmaLinux9Podman

```shell
wget -O ~/AlmaLinux9Podman.sh https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux9Podman.sh && sh ~/AlmaLinux9Podman.sh "${sshPublicKey}" "${prettyHostname}" "${staticHostName}" && rm -f ~/AlmaLinux9Podman.sh
```

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

#### 新建 Swap

```shell

```
