#!/bin/bash

# 请确保你以root权限运行此脚本
if [ "$(id -u)" != "0" ]; then
   echo "请以root用户身份运行此脚本" 1>&2
   exit 1
fi

# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "用法：./auto_detect_format_mount.sh <挂载目录>"
    exit 1
fi

MOUNT_DIR=$1

# 检查挂载目录是否存在
if [ ! -d "$MOUNT_DIR" ]; then
    echo "错误：挂载目录不存在"
    exit 1
fi

# 检测新硬盘
echo "正在检测新硬盘..."
DISK_DEVICE=$(lsblk -lpn -o NAME,TYPE | grep -w "disk" | awk '!/part/ {print $1}' | while read -r disk; do if [ -z "$(lsblk -l -p -o NAME,TYPE | grep -w "part" | awk -v disk="$disk" '$0 ~ disk')" ]; then echo $disk; break; fi; done)

if [ -z "$DISK_DEVICE" ]; then
    echo "未检测到新硬盘。"
    exit 1
fi

echo "检测到新硬盘：$DISK_DEVICE"

# 使用fdisk创建分区
echo "正在创建分区..."
(
echo o  # 创建新的空DOS分区表
echo n  # 添加新分区
echo p  # 指定为主分区
echo 1  # 分区号
echo    # 起始扇区（默认）
echo    # 结束扇区（默认）
echo w  # 写入分区表并退出
) | fdisk $DISK_DEVICE

# 同步磁盘分区信息
partprobe

# 获取新分区设备名称
PARTITION_DEVICE=$(lsblk -l -p -o NAME,TYPE | grep -w "part" | awk -v disk="$DISK_DEVICE" '$0 ~ disk {print $1; exit}')

if [ -z "$PARTITION_DEVICE" ]; then
    echo "未能创建新分区。"
    exit 1
fi

# 格式化分区
echo "正在格式化分区..."
mkfs.ext4 $PARTITION_DEVICE

# 挂载分区
echo "正在挂载分区..."
mount $PARTITION_DEVICE $MOUNT_DIR

# 将挂载信息写入 /etc/fstab
echo "将挂载信息写入 /etc/fstab..."
UUID=$(blkid -s UUID -o value $PARTITION_DEVICE)
echo "UUID=$UUID $MOUNT_DIR ext4 defaults 0 0" >> /etc/fstab

# 完成
echo "新硬盘已格式化并挂载到 $MOUNT_DIR。"

