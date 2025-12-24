# Server Automation Scripts

小汐个人服务器自动化维护脚本，适用于 AlmaLinux 8 & AlmaLinux 9 & AlmaLinux 10 及其兼容服务器，所有脚本均需以 root 权限运行。

## 目录

### 服务器维护 / ServerMaintenance

- [备份 / Backup](#备份--backup)
  - [将容器数据备份到 S3 / backupContainerToS3](#将容器数据备份到-s3--backupcontainertos3)
  - [将 MariaDB 10 数据库备份到 S3 / backupMariaDB10DatabaseToS3](#将-mariadb-10-数据库备份到-s3--backupmariadb10databasetos3)
  - [将 MariaDB 11 数据库备份到 S3 / backupMariaDB11DatabaseToS3](#将-mariadb-11-数据库备份到-s3--backupmariadb11databasetos3)
  - [将 PostgreSQL 14 数据库备份到 S3 / backupPostgreSQL14DatabaseToS3](#将-postgresql-14-数据库备份到-s3--backuppostgresql14databasetos3)
  - [将 PostgreSQL 16 数据库备份到 S3 / backupPostgreSQL16DatabaseToS3](#将-postgresql-16-数据库备份到-s3--backuppostgresql16databasetos3)
  - [将 PostgreSQL 17 数据库备份到 S3 / backupPostgreSQL17DatabaseToS3](#将-postgresql-17-数据库备份到-s3--backuppostgresql17databasetos3)
- [操作系统初始化配置 / FirstInstallation](#操作系统初始化配置--firstinstallation)
  - [AlmaLinux 8 + Podman / AlmaLinux8Podman](#almalinux-8--podman--almalinux8podman)
  - [AlmaLinux 9 + Podman / AlmaLinux9Podman](#almalinux-9--podman--almalinux9podman)
  - [AlmaLinux 9 + Workstation / AlmaLinux9Workstation](#almalinux-9--workstation--almalinux9workstation)
  - [AlmaLinux 10 + Podman / AlmaLinux10Podman](#almalinux-10--podman--almalinux10podman)
  - [AlmaLinux 10 + Podman Public Image / AlmaLinux10PodmanPublicImage](#almalinux-10--podman-public-image--almalinux10podmanpublicimage)
  - [AlmaLinux 10 + Workstation / AlmaLinux10Workstation](#almalinux-10--workstation--almalinux10workstation)
- [证书管理 / Cert](#证书管理--cert)
  - [安装 acme.sh / installAcme](#安装-acmesh--installacme)
  - [使用 Cloudflare DNS API 获取证书 / getCertWithCloudflare](#使用-cloudflare-dns-api-获取证书--getcertwithcloudflare)
  - [在容器内使用 Cloudflare DNS API 获取证书 / getCertWithCloudflareInContainer](#在容器内使用-cloudflare-dns-api-获取证书--getcertwithcloudFlareincontainer)
  - [安装证书 / installCert](#安装证书--installcert)
  - [在容器内安装证书 / installCertInContainer](#在容器内安装证书--installcertincontainer)
- [DNS 管理 / DNS](#dns-管理--dns)
  - [设置 AdGuard DNS / setAdGuard](#设置-adguard-dns--setadguard)
  - [设置 Cloudflare DNS / setCloudflare](#设置-cloudflare-dns--setcloudflare)
  - [设置 Google DNS / setGoogle](#设置-google-dns--setgoogle)
  - [设置 Yandex DNS / setYandex](#设置-yandex-dns--setyandex)
- [驱动配置 / Driver](#驱动配置--driver)
  - [AlmaLinux 10 + Surface Pro 4 / AlmaLinux10SurfacePro4](#almalinux-10--surface-pro-4--almalinux10surfacepro4)
- [额外模块 / Model](#额外模块--model)
  - [安装 Microsoft Edge 浏览器 / installMicrosoftEdge](#安装-microsoft-edge-浏览器--installmicrosoftedge)
  - [安装 NVIDIA 驱动程序 / installNvidiaDriver](#安装-nvidia-驱动程序--installnvidiadriver)
  - [安装 Tailscale / installTailscale](#安装-tailscale--installtailscale)
  - [安装 Tailnet DERP 服务器 / installTailnetDerpServer](#安装-tailnet-derp-服务器--installtailnetderpserver)
  - [安装 Tor / installTor](#安装-tor--installtor)
- [Podman 容器管理 / Podman](#podman-容器管理--podman)
  - [禁用自动升级定时器 / disableAutoUpdateTimer](#禁用自动升级定时器--disableautoupdatetimer)
  - [启用新容器的自动升级 / newAutoUpdateContainer](#启用新容器的自动升级--newautoupdatecontainer)
  - [移除已配置自动升级的容器 / removeAutoUpdateContainer](#移除已配置自动升级的容器--removeautoupdatecontainer)
- [Swap 管理 / Swap](#swap-管理--swap)
  - [新建 Swap / newSwap](#新建-swap--newswap)
  - [调整 Swap 大小 / resizeSwap](#调整-swap-大小--resizeswap)
  - [移除 Swap / removeSwap](#移除-swap--removeswap)

### 容器定制化 / Container

- [caddy2](#caddy2)
  - [自动同步 Nice Caddyfile 中的复用块 / autoSyncNiceCaddyfile](#自动同步-nice-caddyfile-中的复用块--autosyncoicecaddyfile)
- [elasticsearch](#elasticsearch)
  - [系统内核参数配置 / sysctl](#系统内核参数配置--sysctl)
- [gitlab](#gitlab)
  - [定时任务 / cron](#定时任务--cron)
  - [更新 GitLab nginx real_ip_trusted_addresses 配置 / updateRealIpTrustedAddresses](#更新-gitlab-nginx-real_ip_trusted_addresses-配置--updaterealiptrustedaddresses)
- [gitlab-pages](#gitlab-pages)
  - [定时任务 / cron](#定时任务--cron-1)
- [gitlab-runner](#gitlab-runner)
  - [定时任务 / cron](#定时任务--cron-2)
- [image-transfer-station](#image-transfer-station)
  - [定时任务 / cron](#定时任务--cron-3)
- [keycloak](#keycloak)
  - [系统内核参数配置 / sysctl](#系统内核参数配置--sysctl-1)
- [mastodon](#mastodon)
  - [定时任务 / cron](#定时任务--cron-4)
  - [系统内核参数配置 / sysctl](#系统内核参数配置--sysctl-2)
- [redis](#redis)
  - [系统内核参数配置 / sysctl](#系统内核参数配置--sysctl-3)
- [typecho](#typecho)
  - [定时任务 / cron](#定时任务--cron-5)

## 服务器维护 / ServerMaintenance

### 备份 / Backup

#### 将容器数据备份到 S3 / backupContainerToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupContainerToS3.sh | sudo bash -s -- "${serverName}" "podman" "${s3AccessKey}" "${s3SecretKey}" "${s3ApiAddress}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

#### 将 MariaDB 10 数据库备份到 S3 / backupMariaDB10DatabaseToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupMariaDB10DatabaseToS3.sh | sudo bash -s -- "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

#### 将 MariaDB 11 数据库备份到 S3 / backupMariaDB11DatabaseToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupMariaDB11DatabaseToS3.sh | sudo bash -s -- "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

#### 将 PostgreSQL 14 数据库备份到 S3 / backupPostgreSQL14DatabaseToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL14DatabaseToS3.sh | sudo bash -s -- "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

#### 将 PostgreSQL 16 数据库备份到 S3 / backupPostgreSQL16DatabaseToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL16DatabaseToS3.sh | sudo bash -s -- "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

#### 将 PostgreSQL 17 数据库备份到 S3 / backupPostgreSQL17DatabaseToS3

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Backup/backupPostgreSQL17DatabaseToS3.sh | sudo bash -s -- "${serverName}" "${containerName}" "${databaseUser}" "${databasePassword}" "${s3BucketName}" "${s3StorageClass}" "${timerTime}"
```

### 操作系统初始化配置 / FirstInstallation

#### AlmaLinux 8 + Podman / AlmaLinux8Podman

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux8Podman.sh | sudo bash -s -- "${sshPublicKey}" "${prettyHostname}" "${staticHostname}"
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语

#### AlmaLinux 9 + Podman / AlmaLinux9Podman

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux9Podman.sh | sudo bash -s -- "${sshPublicKey}" "${prettyHostname}" "${staticHostname}"
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语

#### AlmaLinux 9 + Workstation / AlmaLinux9Workstation

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux9Workstation.sh | sudo bash
```

#### AlmaLinux 10 + Podman / AlmaLinux10Podman

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux10Podman.sh | sudo bash -s -- "${sshPublicKey}" "${prettyHostname}" "${staticHostname}"
```

脚本执行完成后续执行：

1. 使用 `passwd` 修改 root 用户密码
2. 编辑 `/etc/motd` 以定义欢迎语

#### AlmaLinux 10 + Podman Public Image / AlmaLinux10PodmanPublicImage

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux10PodmanPublicImage.sh | sudo bash
```

脚本执行完成后续执行：

1. 使用 `history -c` 清除历史记录

#### AlmaLinux 10 + Workstation / AlmaLinux10Workstation

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/FirstInstallation/AlmaLinux10Workstation.sh | sudo bash
```

### 证书管理 / Cert

#### 安装 acme.sh / installAcme

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Cert/installAcme.sh | sudo bash -s -- "${acmeEmail}" "${chinaNet}"
```

#### 使用 Cloudflare DNS API 获取证书 / getCertWithCloudflare

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Cert/getCertWithCloudflare.sh | sudo bash -s -- "${domainName}" "${cloudflareToken}" "${cloudflareAccountID}"
```

#### 在容器内使用 Cloudflare DNS API 获取证书 / getCertWithCloudflareInContainer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Cert/getCertWithCloudflareInContainer.sh | sudo bash -s -- "${domainName}" "podman" "acme-sh"
```

#### 安装证书 / installCert

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Cert/installCert.sh | sudo bash -s -- "${domainName}" "${fullChainFilePath}" "${privateKeyFilePath}" "${reloadCommand}"
```

#### 在容器内安装证书 / installCertInContainer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Cert/installCertInContainer.sh | sudo bash -s -- "${domainName}" "${fullChainFilePath}" "${privateKeyFilePath}" "${reloadCommand}" "podman" "acme-sh"
```

### DNS 管理 / DNS

#### 设置 AdGuard DNS / setAdGuard

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/DNS/setAdGuard.sh | sudo bash
```

#### 设置 Cloudflare DNS / setCloudflare

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/DNS/setCloudflare.sh | sudo bash
```

#### 设置 Google DNS / setGoogle

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/DNS/setGoogle.sh | sudo bash
```

#### 设置 Yandex DNS / setYandex

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/DNS/setYandex.sh | sudo bash
```

### 驱动配置 / Driver

#### AlmaLinux 10 + Surface Pro 4 / AlmaLinux10SurfacePro4

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Driver/AlmaLinux10SurfacePro4.sh | sudo bash
```

### 额外模块 / Model

#### 安装 Microsoft Edge 浏览器 / installMicrosoftEdge

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Model/installMicrosoftEdge.sh | sudo bash
```

#### 安装 NVIDIA 驱动程序 / installNvidiaDriver

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Model/installNvidiaDriver.sh | sudo bash
```

脚本执行完成后续执行：

1. 重启服务器以加载 NVIDIA 内核模块

**注意**：此脚本仅支持 AlmaLinux 9 及以上版本

#### 安装 Tailscale / installTailscale

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Model/installTailscale.sh | sudo bash -s -- "${authKey}" "${loginServer}" "${isJumpServer}"
```

#### 安装 Tailnet DERP 服务器 / installTailnetDerpServer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Model/installTailnetDerpServer.sh | sudo bash -s -- "${derpDomain}"
```

#### 安装 Tor / installTor

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Model/installTor.sh | sudo bash
```

### Podman 容器管理 / Podman

#### 禁用自动升级定时器 / disableAutoUpdateTimer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Podman/disableAutoUpdateTimer.sh | sudo bash
```

#### 启用新容器的自动升级 / newAutoUpdateContainer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Podman/newAutoUpdateContainer.sh | sudo bash -s -- "${containerName}"
```

#### 移除已配置自动升级的容器 / removeAutoUpdateContainer

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Podman/removeAutoUpdateContainer.sh | sudo bash -s -- "${containerName}"
```

### Swap 管理 / Swap

#### 新建 Swap / newSwap

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Swap/newSwap.sh | sudo bash -s -- "${swapSize}" "/swapfile"
```

#### 调整 Swap 大小 / resizeSwap

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Swap/resizeSwap.sh | sudo bash -s -- "${swapSize}" "/swapfile"
```

#### 移除 Swap / removeSwap

```bash
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Swap/removeSwap.sh | sudo bash -s -- "/swapfile"
```

## 容器定制化 / Container

### caddy2

#### 自动同步 Nice Caddyfile 中的复用块 / autoSyncNiceCaddyfile

```bash
curl -fsSL https://sh.soraharu.com/Container/caddy2/autoSyncNiceCaddyfile.sh | sudo bash -s -- "podman"
```

### elasticsearch

#### 系统内核参数配置 / sysctl

```bash
curl -fsSL https://sh.soraharu.com/Container/elasticsearch/sysctl.sh | sudo bash
```

### gitlab

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/gitlab/cron.sh | sudo bash
```

#### 自动更新 GitLab real_ip 配置 / updateRealIpTrustedAddresses

```bash
curl -fsSL https://sh.soraharu.com/Container/gitlab/updateRealIpTrustedAddresses.sh | sudo bash -s -- "${providers}" "podman"
```

### gitlab-pages

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/gitlab-pages/cron.sh | sudo bash
```

### gitlab-runner

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/gitlab-runner/cron.sh | sudo bash
```

### image-transfer-station

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/image-transfer-station/cron.sh | sudo bash
```

### keycloak

#### 系统内核参数配置 / sysctl

```bash
curl -fsSL https://sh.soraharu.com/Container/keycloak/sysctl.sh | sudo bash
```

### mastodon

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/mastodon/cron.sh | sudo bash
```

#### 系统内核参数配置 / sysctl

```bash
curl -fsSL https://sh.soraharu.com/Container/mastodon/sysctl.sh | sudo bash
```

### redis

#### 系统内核参数配置 / sysctl

```bash
curl -fsSL https://sh.soraharu.com/Container/redis/sysctl.sh | sudo bash
```

### typecho

#### 定时任务 / cron

```bash
curl -fsSL https://sh.soraharu.com/Container/typecho/cron.sh | sudo bash
```
