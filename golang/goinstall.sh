#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: 请使用root用户运行该脚本"
    exit 1
fi

#判断是否已经安装了go
go version &> /dev/null
if [ $? -eq 0 ]; then
	echo "您已经安装了go,不用再次安装"
	echo "Bye V_V"
	exit 0
fi

#验证是否安装了curl
curl --version &> /dev/null
if [ $? -ne 0 ]; then
	echo "请首先安装curl"
	exit 0
fi

#下载最新的go版本
gourl=$(curl -s  https://studygolang.com/dl |  sed -n '/dl\/golang\/go.*\.linux-amd64\.tar\.gz/p' | sed -n '1p' | sed -n '/1/p' | awk 'BEGIN{FS="\""}{print $4}')
goweb="https://studygolang.com"
gourl="${goweb}${gourl}"
#防止已经下载过
if [ ! -f "$(ls | grep linux-amd64.tar.gz | sed -n '1p')" ]; then
    wget $gourl
    if [ $? -ne 0 ]; then
    	echo "获取安装包失败，请联系作者，微信：962310113"
    	exit 1
    fi
fi

gosrc=$(ls | grep linux-amd64.tar.gz | sed -n '1p')

#下载完成后加压到对应的目录
installPath="/usr/local"
if [[ -f "$gosrc" ]] && [[ -d "$installPath" ]] && [[ ! -d "$installPath/go" ]]; then
	tar -C /usr/local -zxvf  $gosrc
	if [ $? -ne 0 ]; then
    	echo "解压失败，请联系作者，微信：962310113"
    	exit 1
    fi
fi

# 导入环境变量
pathFile="/etc/profile"
if[ ! -f "$pathFile" ]; then
	echo "$pathFile 文件不存在"
	exit 1
fi

echo 'export GOROOT=/usr/local/go' >> $pathFile
if [ $? -ne 0 ]; then
	echo "导入环境变量失败，请联系作者，微信：962310113"
	exit 1
fi
echo 'export PATH=$PATH:$GOROOT/bin' >> $pathFile
if [ $? -ne 0 ]; then
	echo "导入环境变量失败，请联系作者，微信：962310113"
	exit 1
fi
source $pathFile
if [ $? -ne 0 ]; then
	echo "导入环境变量失败，请联系作者，微信：962310113"
	exit 1
fi

#再次验证安装
go version
if [ $? -eq 0 ]; then
	echo "您已经成功安装了go"
	echo "Bye V_V"
	exit 0
else
	echo "安装失败"
	exit 1
fi