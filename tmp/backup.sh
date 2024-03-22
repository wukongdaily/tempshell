#!/bin/sh
# wget -O backup.sh https://raw.githubusercontent.com/wukongdaily/tempshell/master/tmp/backup.sh && chmod +x backup.sh 
# sh backup.sh mt-6000 xxxxx
model=$1
pw=$2
backup_to_nas() {
    
    mkdir -p /mnt/nas/$model
    opkg update
    echo "安装 Cifs 用于挂载NAS空间"
    opkg install kmod-fs-cifs cifsmount
    mount -t cifs //192.168.66.237/IntelSSD /mnt/nas -o username=wukong,password=$pw,iocharset=utf8
    cd /mnt/nas/$model
    echo "备份overlay"
    tar czvf overlay-backup.tar.gz /overlay
    echo "备份已安装列表"
    opkg list-installed >packages-list.txt
    echo "备份OPKG配置"
    wget https://raw.githubusercontent.com/wukongdaily/gl-inet-onescript/master/$model/distfeeds.conf
    echo "拷贝恢复脚本"
    cp /mnt/nas/mt2500/recovery recovery
    ls
}

backup_to_nas $model $pw