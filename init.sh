#!/bin/bash

echo "提示：请以 root 用户运行此脚本"

echo "移除原来的gost文件"
rm -rf gost-linux-amd64-*

echo "下载 gost 源代码，版本 v2.10.0"
wget "https://github.com/ginuerzh/gost/releases/download/v2.10.0/gost-linux-amd64-2.10.0.gz"

echo "下载解压工具"
yum install -y gzip

echo "解压 gost 源码压缩包"
gzip -d gost-linux-amd64-2.10.0.gz
pid = `ps -ef | grep gost | grep -v 'grep' | awk '{print $2}'`
if [ -n "$pid" ]        
then
	echo "杀死 gost 原进程，进程 id 为 $pid"
	kill -9 $pid
fi   

echo "添加 gost 可执行命令"
mv -f gost-linux-amd64-2.10.0 /usr/bin/gost
chmod +x /usr/bin/gost


echo "添加 gost 服务"
echo "[Unit]
Description=create a socks5 proxy by gost
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/gost -L socks5://:8080 
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/socksproxy.service


echo "刷新 service"
systemctl daemon-reload

echo "设置代理服务开机自启"

systemctl enable socksproxy.service

echo "启动代理服务"
systemctl start socksproxy.service

echo "代理服务启动状态如下，看到绿色的 'active(runing)' 字符证明服务启动成功"
systemctl status socksproxy.service
