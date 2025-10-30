#!/bin/bash

# Model - installTailnetDerpServer
#
# 安装 Tailnet DERP 服务器
#
# Author:	XiaoXi<admin@soraharu.com>
# Website:	https://sh.soraharu.com/
# License:	MIT License

# DERP 服务域名
derpDomain=$1

# 检查变量
if [[ -z "${derpDomain}" ]]; then
	echo "错误：输入变量不正确"
	exit 1
fi

# 检查证书文件是否存在
certFile="/podmandirectory/derper-server/certs/${derpDomain}.crt"
keyFile="/podmandirectory/derper-server/certs/${derpDomain}.key"
if [[ ! -f "${certFile}" || ! -f "${keyFile}" ]]; then
	echo "错误：证书文件不存在"
	echo "缺少文件：${certFile} 或 ${keyFile}"
	exit 1
fi

# 检查 tailscaled.sock 文件是否存在
tailscaleSock="/var/run/tailscale/tailscaled.sock"
if [[ ! -S "${tailscaleSock}" ]]; then
	echo "错误：Tailscale socket 文件不存在，请确保 Tailscale 服务已安装并正在运行"
	echo "缺少文件：${tailscaleSock}"
	exit 1
fi

# 创建 derper-server 容器
podman container run \
    --cpu-shares=1024 \
    --detach \
    --env=DERP_DOMAIN="${derpDomain}" \
    --env=DERP_CERT_MODE=manual \
    --env=DERP_ADDR=:51303 \
    --env=DERP_STUN=true \
    --env=DERP_HTTP_PORT=-1 \
    --env=DERP_VERIFY_CLIENTS=true \
    --ip=10.90.0.68 \
    --ip6=fd00::1:8:68 \
    --name=derper-server \
    --network=podman1 \
	--publish=3478:3478/tcp \
	--publish=3478:3478/udp \
    --publish=51303:51303/tcp \
    --quiet \
    --replace \
    --restart=always \
    --tls-verify \
    --volume=/podmandirectory/derper-server/certs/:/app/certs/ \
    --volume=/var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
    ghcr.io/fredliang44/derper:latest

# 配置容器自动更新
curl -fsSL https://sh.soraharu.com/ServerMaintenance/Podman/newAutoUpdateContainer.sh | bash -s -- "derper-server"

# 配置防火墙，启用 STUN 服务端口
firewall-cmd --permanent --zone=public --new-service=stun
firewall-cmd --permanent --service=stun --add-port=3478/tcp --add-port=3478/udp
firewall-cmd --permanent --zone=public --add-service=stun
firewall-cmd --reload

echo "请注意在外部防火墙放行 3478/tcp 3478/udp 51303/tcp 端口"
