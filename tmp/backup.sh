#!/bin/sh
# wget -O backup.sh https://raw.githubusercontent.com/wukongdaily/tempshell/master/tmp/backup.sh && chmod +x backup.sh
# sh backup.sh mt-6000 xxxxx
# 检查是否传入了两个参数
if [ "$#" -ne 2 ]; then
    echo "使用方法: $0 <型号> <密码>"
    echo "示例: $0 mt-6000 yourpassword"
    exit 1
fi
model=$1
pw=$2
backup_to_nas() {
    mkdir -p /mnt/nas
    opkg update
    echo "安装 Cifs 用于挂载NAS空间"
    opkg install kmod-fs-cifs cifsmount
    # 定义NAS共享和挂载点
    nas_share="//192.168.66.237/IntelSSD"
    mount_point="/mnt/nas"
    # 检查NAS是否已经挂载到了指定的挂载点
    if mount | grep -q "$nas_share on $mount_point"; then
        echo "NAS已经成功挂载到$mount_point。"
    else
        # 尝试挂载NAS
        mount -t cifs "$nas_share" "$mount_point" -o username=wukong,password=$pw,iocharset=utf8
        # 检查mount命令的退出状态
        if [ $? -eq 0 ]; then
            echo "NAS挂载成功!"
        else
            echo "NAS挂载失败,请检查命令和网络设置。"
            return 1
        fi
    fi
    cd /mnt/nas
    mkdir -p /mnt/nas/$model
    cd /mnt/nas/$model
    echo "正在备份overlay 到 $pwd"
    tar czvf overlay-backup.tar.gz /overlay >/dev/null 2>&1
    echo "正在备份已安装列表到 $pwd"
    opkg list-installed >packages-list.txt
    echo "备份OPKG配置"

    if [ "$model" = "mt-6000" ]; then
        kernel_version=$(uname -r)
        echo "$model kernel version: $kernel_version"
        case $kernel_version in
        5.4*)
            mt6000_opkg="https://raw.githubusercontent.com/wukongdaily/gl-inet-onescript/master/mt-6000/distfeeds-5.4.conf"
            ;;
        5.15*)
            mt6000_opkg="https://raw.githubusercontent.com/wukongdaily/gl-inet-onescript/master/mt-6000/distfeeds.conf"
            ;;
        *)
            echo "Unsupported kernel version: $kernel_version"
            return 1
            ;;
        esac
        wget -O distfeeds.conf ${mt6000_opkg}
    else
        wget https://raw.githubusercontent.com/wukongdaily/gl-inet-onescript/master/$model/distfeeds.conf
    fi
    echo "拷贝恢复脚本"
    cp /mnt/nas/mt2500/recovery recovery
    ls
}

backup_to_nas $model $pw
