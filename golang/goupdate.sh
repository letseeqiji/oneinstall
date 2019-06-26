#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

goone_ver=1.0.2
give_info="请联系作者，QQ：962310113"

clear
echo "+------------------------------------------------------------------------+"
echo "|          GO一键安装包 V${goone_ver} for Linux, Written by Letseeqiji         |"
echo "+------------------------------------------------------------------------+"
echo "|           有问题${give_info}         			 |"
echo "+------------------------------------------------------------------------+"

#判断是否已经安装了go  然后判断安装版本是否低于当前版本 如果低于最新版 提示升级 并且安装到原来安装的位置
# 首先仅仅先支持使用 源码安装的版本  不支持 yum 和 apt的版本
go version &> /dev/null
if [ $? -eq 0 ]; then
	echo -e -n "\033[01;36m您已经安装了go,不用再次安装\033[0m "
	echo -e -n "\033[01;36mBye ^_^\033[0m "
	exit 0
fi

exit 0

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

# 导入之前应该先判断是否已经设置过对应的值[不仅仅是etc/profile这一个配置文件] 如果设置过  提示 1-覆盖 2-跳过并手动添加
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
echo 'export GOPATH=$USER/go/src' >> $pathFile
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
	
	echo -e -n "\033[01;36m下面将为您自动导入 golang.org/x 包\033[0m "
	export_goorg_x
	echo -e -n "\033[01;36mBye V_V"
	exit 0
else
	echo -e -n "\033[01;36m安装失败\033[0m "
	exit 1
fi

export_goorg_x()
{
	cd $GOPATH;
	if [ $? -ne 0 ]; then
		echo -e -n "\033[01;36m没有找到 ${GOPATH}\033[0m "
		return
	fi
	#创建 $GOPATH/src/golang.org/x 目录
	mkdir -p src/golang.org/x
	cd src/golang.org/x
	echo -e -n "\033[01;36m已经安装的golang.org/x package[0m "
	ls
	echo -e -n "\033[01;36m下面一行 for in 中包的名字您可以自己来定义[0m "
	for name in "text" "glog" "image" "perf" "snappy" "term" "sync" "winstrap" "cwg" "leveldb" "net" "build" "protobuf" "dep" "sys" "crypto" "gddo" "tools" "scratch" "proposal" "mock" "oauth2" "freetype" "debug" "mobile" "gofrontend" "lint" "appengine" "geo" "review" "arch" "vgo" "exp" "time";do
	   if [ -d "$name" ]
	   then
		 cd $name
		 echo -e -n "\033[01;36m ${name} 包已经存在,请使用git pull来更新源码[0m "
		 git pull;
	   else
		 git_url="https://github.com/golang/${name}.git";
		 echo -e -n "\033[01;36m开始clone golang.org/x 在github.com上的镜像代码:${git_url}[0m "
		 git clone --depth 1 "$git_url"
		 cd $name
	   fi
	done
}

# 安装完成后可选自动部署一个简易的框架及简单的项目目录 包含常用的模块目录和案例  形成一个自动化的脚手架
