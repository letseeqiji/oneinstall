[![Language](https://img.shields.io/badge/Language-Shell-blue.svg)](https://github.com/letseeqiji/git-helper)
[![Build Status](https://travis-ci.org/bilibili/kratos.svg?branch=master)](https://github.com/letseeqiji/git-helper)

# 一键自动安装配置GO最新版脚本

一键自动安装配置GO最新版脚本是linux命令行下工作的开源辅助工具。  

> Golang语言日渐受到很多人的喜欢，但是安装和配置golang尤其是对于频繁安装测试和学习的人员来说毕竟需要学习和花费一定的时间，而这个脚本可以自动完成最新版的安装和配置工作，大大降低了学习成本和配置时间。

## 目标

> 致力于提供更加方便快捷的操作方式，节省更多的时间去创造更具价值的东西。

## 特色

- 自动完成相关环境的检测和提示;
- 自动检测最新版本的GO安装包并下载;
- 自动导入GOPATH和PATH;

## 待完成：期待您的共同参与

- 环境依赖的完全自动化安装;
- 不同平台和版本的完善;
- 更加多的定制化服务;
- more and more... ...。 

### **部分代码**

```bash
......
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
......
```

## 快速开始

### 获取

```shell
git clone https://github.com/letseeqiji/oneinstall.git
cd oneinstall/golang
其中 goinstall.sh 是主文件，你可以把他复制到任何你想要的目录下面使用并且根据相应的提示操作即可
sh goinstall.sh
```

------

## 文档

[简体中文](https://github.com/letseeqiji/oneinstall/blob/master/golang/README.md)

------

*Please report bugs, concerns, suggestions by issues, or join QQ 962310113to discuss problems around source code.*
