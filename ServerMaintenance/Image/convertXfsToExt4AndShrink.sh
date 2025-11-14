#!/bin/bash

################################################################################
# 脚本名称: convertXfsToExt4AndShrink.sh
# 脚本描述: 将 XFS 文件系统的 qcow2 镜像转换为 ext4 并缩小到 4.8G
# 作者: xiaoxis
# 创建日期: 2025-11-14
# 使用方法: sudo ./convertXfsToExt4AndShrink.sh <qcow2文件路径>
# 说明: 通过数据迁移的方式实现 XFS 到 ext4 的转换并缩小镜像
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 清理函数
cleanup() {
    log_info "开始清理..."
    
    # 卸载 chroot 绑定挂载
    if [ -n "$NEW_ROOT_MOUNT" ] && [ -d "$NEW_ROOT_MOUNT" ]; then
        for bind_mount in run sys proc dev; do
            if mountpoint -q "$NEW_ROOT_MOUNT/$bind_mount" 2>/dev/null; then
                log_info "卸载 chroot: $NEW_ROOT_MOUNT/$bind_mount"
                umount "$NEW_ROOT_MOUNT/$bind_mount" 2>/dev/null || true
            fi
        done
    fi
    
    # 卸载数据分区
    for mount_point in "$NEW_ROOT_MOUNT/boot/efi" "$NEW_BOOT_MOUNT" "$NEW_ROOT_MOUNT" "$NEW_EFI_MOUNT" "$OLD_ROOT_MOUNT" "$OLD_BOOT_MOUNT"; do
        if [ -n "$mount_point" ] && mountpoint -q "$mount_point" 2>/dev/null; then
            log_info "卸载: $mount_point"
            umount "$mount_point" 2>/dev/null || true
        fi
    done
    
    # 删除挂载点目录
    for mount_point in "$NEW_ROOT_MOUNT" "$NEW_BOOT_MOUNT" "$NEW_EFI_MOUNT" "$OLD_ROOT_MOUNT" "$OLD_BOOT_MOUNT"; do
        if [ -n "$mount_point" ] && [ -d "$mount_point" ]; then
            rmdir "$mount_point" 2>/dev/null || true
        fi
    done
    
    # 分离 loop 设备
    for loop_dev in "$OLD_LOOP" "$NEW_LOOP"; do
        if [ -n "$loop_dev" ]; then
            log_info "分离 loop 设备: $loop_dev"
            losetup -d "$loop_dev" 2>/dev/null || true
        fi
    done
    
    # 清理临时文件
    if [ "$KEEP_TEMP" != "1" ]; then
        if [ -f "$NEW_RAW" ]; then
            log_info "清理临时文件: $NEW_RAW"
            rm -f "$NEW_RAW"
        fi
        if [ -f "$OLD_RAW" ]; then
            log_info "清理临时文件: $OLD_RAW"
            rm -f "$OLD_RAW"
        fi
    fi
}

trap cleanup EXIT INT TERM

# 检查参数
if [ $# -ne 1 ]; then
    log_error "用法: $0 <qcow2文件路径>"
    echo "示例: $0 /path/to/almalinux.qcow2"
    exit 1
fi

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    log_error "此脚本需要 root 权限运行"
    log_error "请使用: sudo $0 $1"
    exit 1
fi

QCOW2_FILE="$1"
TARGET_SIZE_GB=4.8
TARGET_SIZE_MB=4915

# 检查输入文件
if [ ! -f "$QCOW2_FILE" ]; then
    log_error "文件不存在: $QCOW2_FILE"
    exit 1
fi

# 检查必要工具
for cmd in qemu-img parted losetup mkfs.ext4 mkfs.vfat rsync grub2-install; do
    if ! command -v $cmd &> /dev/null; then
        log_error "缺少必要工具: $cmd"
        log_error "请安装: sudo dnf install qemu-img parted e2fsprogs dosfstools rsync grub2-tools"
        exit 1
    fi
done

# 生成文件路径
BASE_NAME=$(basename "$QCOW2_FILE" .qcow2)
OUTPUT_DIR=$(dirname "$QCOW2_FILE")
OUTPUT_FILE="${OUTPUT_DIR}/${BASE_NAME}-4.8G-ext4.raw"
NEW_RAW="${OUTPUT_DIR}/${BASE_NAME}-new.raw"

log_info "========================================"
log_info "XFS 转 ext4 并缩小到 4.8G"
log_info "========================================"
log_info "源文件: $QCOW2_FILE"
log_info "目标文件: $OUTPUT_FILE"
log_info "目标大小: ${TARGET_SIZE_GB}G"
log_info ""

# 显示原始镜像信息
log_step "步骤 1/10: 查看原始镜像信息"
qemu-img info "$QCOW2_FILE"
echo ""

# 转换 qcow2 到 raw
log_step "步骤 2/10: 转换 qcow2 到 raw 格式"
OLD_RAW="${OUTPUT_DIR}/${BASE_NAME}-old.raw"
log_info "转换中..."
qemu-img convert -f qcow2 -O raw "$QCOW2_FILE" "$OLD_RAW"
log_info "转换完成: $OLD_RAW"
echo ""

# 挂载原始镜像
log_step "步骤 3/11: 挂载原始镜像"
OLD_LOOP=$(losetup -fP --show "$OLD_RAW")
log_info "原始镜像 loop 设备: $OLD_LOOP"

# 刷新分区表并等待
partprobe "$OLD_LOOP" 2>/dev/null || true
sleep 3
udevadm settle 2>/dev/null || sleep 2

# 显示分区信息
log_info "原始分区信息:"
lsblk -f "$OLD_LOOP"
echo ""

# 检查分区（尝试两种命名方式）
OLD_ROOT_PART="${OLD_LOOP}p4"  # root 分区
OLD_BOOT_PART="${OLD_LOOP}p3"  # boot 分区
OLD_EFI_PART="${OLD_LOOP}p2"   # EFI 分区

if [ ! -e "$OLD_ROOT_PART" ]; then
    # 尝试不带 p 的格式
    OLD_ROOT_PART="${OLD_LOOP}4"
    OLD_BOOT_PART="${OLD_LOOP}3"
    OLD_EFI_PART="${OLD_LOOP}2"
fi

if [ ! -e "$OLD_ROOT_PART" ]; then
    log_error "未找到 root 分区: $OLD_ROOT_PART"
    log_error "可用的块设备:"
    lsblk "$OLD_LOOP"
    exit 1
fi

log_info "Root 分区: $OLD_ROOT_PART"
log_info "Boot 分区: $OLD_BOOT_PART"
log_info "EFI 分区: $OLD_EFI_PART"

# 检查文件系统使用情况
log_step "步骤 3/11: 检查磁盘使用情况"
OLD_ROOT_MOUNT=$(mktemp -d)
OLD_BOOT_MOUNT=$(mktemp -d)

mount "$OLD_ROOT_PART" "$OLD_ROOT_MOUNT"
mount "$OLD_BOOT_PART" "$OLD_BOOT_MOUNT"

ROOT_USED=$(df -BM "$OLD_ROOT_MOUNT" | tail -1 | awk '{print $3}' | sed 's/M//')
BOOT_USED=$(df -BM "$OLD_BOOT_MOUNT" | tail -1 | awk '{print $3}' | sed 's/M//')
TOTAL_USED=$((ROOT_USED + BOOT_USED + 250))  # 加上 EFI 和余量

log_info "Root 分区使用: ${ROOT_USED}MB"
log_info "Boot 分区使用: ${BOOT_USED}MB"
log_info "预计总使用: ${TOTAL_USED}MB"
log_info "目标空间: 4700MB (可用于数据)"

if [ $TOTAL_USED -gt 4500 ]; then
    log_error "数据使用空间 (${TOTAL_USED}MB) 超过目标大小"
    log_error "无法缩小到 4.8G，请清理原始镜像后再试"
    exit 1
fi

log_info "空间充足，可以继续"
echo ""

# 创建新镜像
log_step "步骤 4/11: 创建新的 4.8G raw 镜像"
dd if=/dev/zero of="$NEW_RAW" bs=1M count=$TARGET_SIZE_MB status=progress
log_info "新镜像创建完成"
echo ""

# 创建分区表
log_step "步骤 5/11: 创建新分区表"
NEW_LOOP=$(losetup -fP --show "$NEW_RAW")
log_info "新镜像 loop 设备: $NEW_LOOP"

# 创建 GPT 分区表
parted "$NEW_LOOP" --script mklabel gpt

# 创建分区
# 1. BIOS Boot 分区 (1MB)
parted "$NEW_LOOP" --script mkpart biosboot 1MiB 2MiB
parted "$NEW_LOOP" --script set 1 bios_grub on

# 2. EFI 分区 (200MB)
parted "$NEW_LOOP" --script mkpart EFI fat32 2MiB 202MiB
parted "$NEW_LOOP" --script set 2 esp on

# 3. Boot 分区 (500MB, ext4)
parted "$NEW_LOOP" --script mkpart boot ext4 202MiB 702MiB

# 4. Root 分区 (剩余空间, ext4)
parted "$NEW_LOOP" --script mkpart root ext4 702MiB 100%

# 刷新分区表
partprobe "$NEW_LOOP"
sleep 2

log_info "新分区表:"
parted "$NEW_LOOP" print
echo ""

# 格式化新分区
log_step "步骤 6/11: 格式化新分区为 ext4"
NEW_EFI_PART="${NEW_LOOP}p2"
NEW_BOOT_PART="${NEW_LOOP}p3"
NEW_ROOT_PART="${NEW_LOOP}p4"

log_info "格式化 EFI 分区为 FAT32..."
mkfs.vfat -F 32 -n "EFI" "$NEW_EFI_PART"

log_info "格式化 Boot 分区为 ext4..."
mkfs.ext4 -F -L "boot" "$NEW_BOOT_PART"

log_info "格式化 Root 分区为 ext4..."
mkfs.ext4 -F -L "root" "$NEW_ROOT_PART"
echo ""

# 挂载新分区
log_step "步骤 7/11: 挂载新分区"
NEW_ROOT_MOUNT=$(mktemp -d)
NEW_BOOT_MOUNT=$(mktemp -d)
NEW_EFI_MOUNT=$(mktemp -d)

mount "$NEW_ROOT_PART" "$NEW_ROOT_MOUNT"
mkdir -p "$NEW_ROOT_MOUNT/boot"
mount "$NEW_BOOT_PART" "$NEW_BOOT_MOUNT"
mkdir -p "$NEW_ROOT_MOUNT/boot/efi"
mount "$OLD_EFI_PART" "$NEW_EFI_MOUNT"

log_info "新分区已挂载"
echo ""

# 复制数据
log_step "步骤 8/11: 复制数据 (这可能需要几分钟)"
log_info "复制 root 文件系统..."
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/boot/*"} \
    "$OLD_ROOT_MOUNT/" "$NEW_ROOT_MOUNT/" | tail -20

log_info "复制 boot 文件系统..."
rsync -aAXv "$OLD_BOOT_MOUNT/" "$NEW_BOOT_MOUNT/" | tail -20

log_info "复制 EFI 分区..."
mkdir -p "$NEW_ROOT_MOUNT/boot/efi"
mount "$NEW_EFI_PART" "$NEW_ROOT_MOUNT/boot/efi"
rsync -aAXv "$NEW_EFI_MOUNT/" "$NEW_ROOT_MOUNT/boot/efi/" | tail -20

log_info "数据复制完成"
echo ""

# 更新 fstab
log_step "步骤 9/11: 更新系统配置"
log_info "更新 /etc/fstab..."

# 获取新分区的 UUID
NEW_ROOT_UUID=$(blkid -s UUID -o value "$NEW_ROOT_PART")
NEW_BOOT_UUID=$(blkid -s UUID -o value "$NEW_BOOT_PART")
NEW_EFI_UUID=$(blkid -s UUID -o value "$NEW_EFI_PART")

log_info "新的 Root UUID: $NEW_ROOT_UUID"
log_info "新的 Boot UUID: $NEW_BOOT_UUID"
log_info "新的 EFI UUID: $NEW_EFI_UUID"

# 创建新的 fstab
cat > "$NEW_ROOT_MOUNT/etc/fstab" << EOF
# /etc/fstab
# Created by convertXfsToExt4AndShrink.sh on $(date)
#
UUID=$NEW_ROOT_UUID  /          ext4    defaults        1 1
UUID=$NEW_BOOT_UUID  /boot      ext4    defaults        1 2
UUID=$NEW_EFI_UUID   /boot/efi  vfat    umask=0077      0 2
EOF

log_info "fstab 已更新"
cat "$NEW_ROOT_MOUNT/etc/fstab"
echo ""

# 重新配置引导系统
log_info "准备 chroot 环境..."
mount --bind /dev "$NEW_ROOT_MOUNT/dev"
mount --bind /proc "$NEW_ROOT_MOUNT/proc"
mount --bind /sys "$NEW_ROOT_MOUNT/sys"
mount --bind /run "$NEW_ROOT_MOUNT/run" 2>/dev/null || true

# 获取内核版本
KERNEL_VER=$(ls "$NEW_BOOT_MOUNT"/vmlinuz-* 2>/dev/null | sed 's/.*vmlinuz-//' | head -1)
if [ -z "$KERNEL_VER" ]; then
    log_warn "未找到内核，跳过 initramfs 重建"
else
    log_info "检测到内核版本: $KERNEL_VER"
    
    # 重新生成 initramfs
    log_info "重新生成 initramfs..."
    
    # 创建 dracut 配置以避免 EFI/Default 错误
    mkdir -p "$NEW_ROOT_MOUNT/etc/dracut.conf.d"
    cat > "$NEW_ROOT_MOUNT/etc/dracut.conf.d/99-custom.conf" << 'DRACUTEOF'
# Disable EFI installation during dracut
install_items+=" "
DRACUTEOF
    
    # 确保 initramfs 目标目录存在
    if [ ! -f "$NEW_BOOT_MOUNT/initramfs-${KERNEL_VER}.img" ]; then
        # 如果原始 initramfs 存在则复制
        if [ -f "$OLD_BOOT_MOUNT/initramfs-${KERNEL_VER}.img" ]; then
            log_info "复制原始 initramfs..."
            cp "$OLD_BOOT_MOUNT/initramfs-${KERNEL_VER}.img" "$NEW_BOOT_MOUNT/"
        fi
    fi
    
    # 在 chroot 中重建 initramfs（如果失败也继续）
    log_info "尝试重建 initramfs（可能会有警告）..."
    chroot "$NEW_ROOT_MOUNT" /bin/bash -c "dracut --force --kver $KERNEL_VER 2>&1 || true" | tail -15
    
    # 清理临时配置
    rm -f "$NEW_ROOT_MOUNT/etc/dracut.conf.d/99-custom.conf"
fi

# 安装 GRUB（BIOS + EFI 双引导）
log_info "配置 GRUB 引导..."

# 创建必要的目录
mkdir -p "$NEW_ROOT_MOUNT/boot/grub2"
mkdir -p "$NEW_ROOT_MOUNT/boot/efi/EFI/almalinux"

# 安装 GRUB 到 BIOS 引导分区
log_info "安装 GRUB (BIOS 模式)..."
if chroot "$NEW_ROOT_MOUNT" grub2-install --target=i386-pc "$NEW_LOOP" 2>&1 | tee /tmp/grub-install.log | tail -10; then
    log_info "GRUB BIOS 模式安装成功"
else
    log_warn "GRUB BIOS 模式安装失败，但 EFI 模式可能仍然工作"
    cat /tmp/grub-install.log | tail -5
fi

# 生成 GRUB 配置
log_info "生成 GRUB 配置文件..."
if chroot "$NEW_ROOT_MOUNT" grub2-mkconfig -o /boot/grub2/grub.cfg 2>&1 | tee /tmp/grub-mkconfig.log | tail -10; then
    log_info "GRUB 配置生成成功"
else
    log_warn "GRUB 配置生成失败，使用默认配置"
    
    # 如果失败，创建一个基本的 grub.cfg
    if [ ! -f "$NEW_ROOT_MOUNT/boot/grub2/grub.cfg" ]; then
        log_info "创建基本 GRUB 配置..."
        cat > "$NEW_ROOT_MOUNT/boot/grub2/grub.cfg" << GRUBEOF
set default=0
set timeout=5

menuentry 'AlmaLinux' {
    insmod gzio
    insmod part_gpt
    insmod ext2
    search --no-floppy --fs-uuid --set=root $NEW_ROOT_UUID
    linux /boot/vmlinuz-${KERNEL_VER} root=UUID=$NEW_ROOT_UUID ro console=tty0 console=ttyS0,115200n8
    initrd /boot/initramfs-${KERNEL_VER}.img
}
GRUBEOF
        log_info "基本 GRUB 配置已创建"
    fi
fi

# 同步 GRUB 配置到 EFI 分区（如果需要）
if [ -f "$NEW_ROOT_MOUNT/boot/efi/EFI/almalinux/grub.cfg" ]; then
    log_info "更新 EFI GRUB 配置..."
    cat > "$NEW_ROOT_MOUNT/boot/efi/EFI/almalinux/grub.cfg" << EFIGRUBEOF
search --no-floppy --fs-uuid --set=root $NEW_ROOT_UUID
set prefix=(\$root)/boot/grub2
configfile \$prefix/grub.cfg
EFIGRUBEOF
fi

# 卸载 chroot 绑定
umount "$NEW_ROOT_MOUNT/run" 2>/dev/null || true
umount "$NEW_ROOT_MOUNT/sys" 2>/dev/null || true
umount "$NEW_ROOT_MOUNT/proc" 2>/dev/null || true
umount "$NEW_ROOT_MOUNT/dev" 2>/dev/null || true

log_info "引导系统配置完成"
echo ""

# 清理和完成
log_step "步骤 10/11: 清理并保存"
log_info "卸载所有分区..."
umount "$NEW_ROOT_MOUNT/boot/efi" 2>/dev/null || true
umount "$NEW_BOOT_MOUNT"
umount "$NEW_ROOT_MOUNT"
umount "$OLD_BOOT_MOUNT"
umount "$OLD_ROOT_MOUNT"
umount "$NEW_EFI_MOUNT" 2>/dev/null || true

# 清空变量避免重复卸载
NEW_ROOT_MOUNT=""
NEW_BOOT_MOUNT=""
OLD_ROOT_MOUNT=""
OLD_BOOT_MOUNT=""

log_info "分离 loop 设备..."
losetup -d "$OLD_LOOP"
losetup -d "$NEW_LOOP"
OLD_LOOP=""
NEW_LOOP=""

log_info "移动到最终位置..."
mv "$NEW_RAW" "$OUTPUT_FILE"
KEEP_TEMP=1

# 打包压缩
log_step "步骤 11/11: 打包压缩"
ARCHIVE_FILE="${OUTPUT_FILE}.tar.gz"
BASENAME_FILE=$(basename "$OUTPUT_FILE")

log_info "开始压缩打包（这可能需要几分钟）..."
log_info "压缩算法: gzip (级别 9)"

# 使用 tar + gzip 压缩，显示进度
if tar -C "$(dirname "$OUTPUT_FILE")" -czf "$ARCHIVE_FILE" --transform "s|.*|$BASENAME_FILE|" "$BASENAME_FILE" 2>&1; then
    ARCHIVE_SIZE=$(ls -lh "$ARCHIVE_FILE" | awk '{print $5}')
    ORIGINAL_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    
    log_info "打包完成！"
    log_info "原始文件: $OUTPUT_FILE ($ORIGINAL_SIZE)"
    log_info "压缩包: $ARCHIVE_FILE ($ARCHIVE_SIZE)"
    
    # 计算压缩比
    ORIGINAL_BYTES=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null)
    ARCHIVE_BYTES=$(stat -c%s "$ARCHIVE_FILE" 2>/dev/null || stat -f%z "$ARCHIVE_FILE" 2>/dev/null)
    if [ -n "$ORIGINAL_BYTES" ] && [ -n "$ARCHIVE_BYTES" ] && [ "$ORIGINAL_BYTES" -gt 0 ]; then
        RATIO=$((100 - (ARCHIVE_BYTES * 100 / ORIGINAL_BYTES)))
        log_info "压缩率: ${RATIO}%"
    fi
else
    log_warn "打包失败，但 raw 文件可用"
fi

# 显示结果
echo ""
log_info "========================================"
log_info "转换完成！"
log_info "========================================"
log_info "输出文件:"
log_info "  - RAW 镜像: $OUTPUT_FILE"
if [ -f "$ARCHIVE_FILE" ]; then
    log_info "  - 压缩包: $ARCHIVE_FILE"
    ARCHIVE_BASENAME=$(basename "$ARCHIVE_FILE")
fi
echo ""
log_info "文件系统已从 XFS 转换为 ext4"
log_info "镜像大小已缩小到 4.8G"
echo ""
log_info "部署命令:"
if [ -f "$ARCHIVE_FILE" ]; then
    log_info "  方式1 (本地部署): tar -xzOf $ARCHIVE_FILE | dd of=/dev/vda bs=1M status=progress"
    log_info "  方式2 (网络部署): curl -Lo- \"https://blog.cdn.soraharu.com/$ARCHIVE_BASENAME\" | tar -xzO | dd of=/dev/vda bs=1M"
    log_info "  方式3 (网络+进度): wget -qO- \"https://blog.cdn.soraharu.com/$ARCHIVE_BASENAME\" | tar -xzO | dd of=/dev/vda bs=1M status=progress"
fi
log_info "  方式4 (直接写入): dd if=$OUTPUT_FILE of=/dev/vda bs=1M status=progress"
echo ""
log_warn "注意: 请在测试环境验证镜像可启动后再部署到生产环境！"

exit 0
