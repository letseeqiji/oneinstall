#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

goone_ver=1.0.1
give_info="请联系作者，微信：962310113"

clear
echo "+------------------------------------------------------------------------+"
echo "|          GO一键安装包 V${goone_ver} for Linux, Written by Letseeqiji         |"
echo "+------------------------------------------------------------------------+"
echo "|           有问题${give_info}         			 |"
echo "+------------------------------------------------------------------------+"

#判断是否已经安装了go
go version &> /dev/null
if [ $? -eq 0 ]; then
	echo -e -n "\033[01;36m您已经安装了go,不用再次安装\033[0m "
	echo -e -n "\033[01;36mBye ^_^\033[0m "
	exit 0
fi

#检查网络是否畅通
ping www.studygolang.com -c 1 &> /dev/null
if [ $? -ne 0 ]; then
	echo -e -n "\033[01;36m网络未能到达源码网站，请检查网络设置或打开www.studygolang.com查看网站是否正常运行\n\033[0m "
	echo -e -n "\033[01;36m如确认没有问题，${give_info}\n\033[0m "
	exit 1
fi

#检查用户是否是root
if [ $(id -u) != "0" ]; then
    echo -e -n "\033[01;36mError: 请使用root用户运行该脚本\n\033[0m "
    exit 1
fi

#验证是否安装了curl
curl --version &> /dev/null
if [ $? -ne 0 ]; then
	echo -e -n "\033[01;36m请首先安装curl\n\033[0m "
	exit 0
fi

echo  -e -n "\033[01;36m当前环境允许安装，你确认要开始安装吗[y|Y]:\033[0m "
read -n1 install_choose
echo -e "\n"
if [[ $install_choose == 'y' ]] || [[ $install_choose == 'Y' ]]; then
	echo -e -n "\033[01;36mOK, 请稍后，马上就好.\n\033[0m "
else
	echo -e -n "\033[01;36m取消成功.\n\033[0m "
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
    	echo -e -n "\033[01;36m获取安装包失败，${give_info}\033[0m "
    	exit 1
    fi
fi

gosrc=$(ls | grep linux-amd64.tar.gz | sed -n '1p')

#下载完成后解压到对应的目录
installPath="/usr/local"
if [[ -f "$gosrc" ]] && [[ -d "$installPath" ]] && [[ ! -d "$installPath/go" ]]; then
	tar -C /usr/local -zxvf  $gosrc
	if [ $? -ne 0 ]; then
    	echo -e -n "\033[01;36m解压失败，${give_info}\033[0m "
    	exit 1
    fi
fi

# 导入环境变量
pathFile="/etc/profile"
if[ ! -f "$pathFile" ]; then
	echo -e -n "\033[01;36m$pathFile 文件不存在\033[0m "
	exit 1
fi

echo 'export GOROOT=/usr/local/go' >> $pathFile
if [ $? -ne 0 ]; then
	echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m "
	exit 1
fi
echo 'export PATH=$PATH:$GOROOT/bin' >> $pathFile
if [ $? -ne 0 ]; then
	echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m "
	exit 1
fi
source $pathFile
if [ $? -ne 0 ]; then
	echo -e -n "\033[01;36m导入环境变量失败，${give_info}\033[0m "
	exit 1
fi

#再次验证安装
go version
if [ $? -eq 0 ]; then
	echo -e -n "\033[01;36m您已经成功安装了go\033[0m "
	echo -e -n "\033[01;36mBye V_V"
	exit 0
else
	echo -e -n "\033[01;36m安装失败\033[0m "
	exit 1
fi