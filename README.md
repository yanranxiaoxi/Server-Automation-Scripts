# Server Automation Scripts

## 服务器维护 / ServerMaintenance

### 备份 / Backup

#### 将容器目录备份到 S3 / backupContainerToS3

```shell

```

### Podman 容器管理 / Podman

#### 禁用自动升级定时器 / disableAutoUpdateTimer

```shell
wget -O ~/disableAutoUpdateTimer.sh https://sh.soraharu.com/ServerMaintenance/Podman/disableAutoUpdateTimer.sh && sh ~/disableAutoUpdateTimer.sh && rm -f ~/disableAutoUpdateTimer.sh
```

#### 启用新容器的自动升级 / newAutoUpdateContainer

```shell
wget -O ~/newAutoUpdateContainer.sh https://sh.soraharu.com/ServerMaintenance/Podman/newAutoUpdateContainer.sh && sh ~/newAutoUpdateContainer.sh "${container_name}" && rm -f ~/newAutoUpdateContainer.sh
```

#### 移除已配置自动升级的容器 / removeAutoUpdateContainer

```shell
wget -O ~/removeAutoUpdateContainer.sh https://sh.soraharu.com/ServerMaintenance/Podman/removeAutoUpdateContainer.sh && sh ~/removeAutoUpdateContainer.sh "${container_name}" && rm -f ~/removeAutoUpdateContainer.sh
```
