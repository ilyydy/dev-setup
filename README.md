# dev-setup

## ubuntu 20.04

运行：

```bash
bash setup.sh 2>&1 | tee /tmp/setup.log
```

debug 模式运行：

```bash
DEBUG=true bash setup.sh 2>&1 | tee /tmp/setup.log
```

## windows 10

### wsl 安装

[WSL 2 的安装说明](https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-install)

### 同一发行版安装多个 wsl 实例

前提：已安装 wsl2

参考：[how-to-add-second-wsl2-ubuntu-distro-fresh-install](https://superuser.com/questions/1515246/how-to-add-second-wsl2-ubuntu-distro-fresh-install)

1. [下载](https://docs.microsoft.com/zh-cn/windows/wsl/install-manual#downloading-distributions) ubuntu 20.04
2. 解压下载的 `Ubuntu_2004.2020.424.0_x64.appx`
3. `powershell` 进入解压后的目录执行命令

```powershell
# <Distribution Name>: 实例名字，需与已有实例不同
# <Install Folder>：实例安装的文件夹
# wsl --import <Distribution Name> <Install Folder> install.tar.gz
$FolderToCreate="C:\ubuntu-20.04-1"
if (!(Test-Path $FolderToCreate -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $FolderToCreate
}
wsl --import Ubuntu-20.04-1 $FolderToCreate install.tar.gz

# 进入实例
wsl -d Ubuntu-20.04-1
```

4. 创建的实例默认用户为 `root`，实例中创建个人用户 `ilyydy` 并修改为默认用户

```bash
# 设定 root 密码
passwd


NEW_USER=ilyydy
adduser "${NEW_USER}"

adduser ${NEW_USER} sudo

tee /etc/wsl.conf <<_EOF
[user]
default=${NEW_USER}
_EOF
```

5. `powershell` 中重启实例使修改生效

```powershell
wsl --terminate Ubuntu-20.04-1
wsl -d Ubuntu-20.04-1
```

6. windows terminal 配置实例

- Ubuntu 主题

```json
{
   "background": "#300A24",
   "black": "#2E3436",
   "blue": "#3465A4",
   "brightBlack": "#555753",
   "brightBlue": "#729FCF",
   "brightCyan": "#34E2E2",
   "brightGreen": "#8AE234",
   "brightPurple": "#AD7FA8",
   "brightRed": "#EF2929",
   "brightWhite": "#EEEEEC",
   "brightYellow": "#FCE94F",
   "cursorColor": "#FFFFFF",
   "cyan": "#06989A",
   "foreground": "#EEEEEC",
   "green": "#4E9A06",
   "name": "Ubuntu",
   "purple": "#75507B",
   "red": "#CC0000",
   "selectionBackground": "#FFFFFF",
   "white": "#D3D7CF",
   "yellow": "#C4A000"
}
```

- 设置启动目录 ```//wsl$/Ubuntu-20.04-1/home/ilyydy```

### 常用软件

- [vscode](https://code.visualstudio.com/download)
- [git](https://git-scm.com/downloads)
- [firefox](https://www.mozilla.org/zh-CN/firefox/download/thanks/)
- [windows terminal](https://github.com/microsoft/terminal)
- [postman](https://www.postman.com/downloads/)
- [Another Redis Desktop Manager](https://github.com/qishibo/AnotherRedisDesktopManager#another-redis-desktop-manager)
- [dbeaver](https://dbeaver.io/download/)
- [idea](https://www.jetbrains.com/zh-cn/idea/download/#section=windows)
- [docker desktop](https://docs.docker.com/docker-for-windows/wsl/)
  - 配置阿里源 ```https://3xr1v0un.mirror.aliyuncs.com```
- [anki](https://apps.ankiweb.net/)
- [Everything](https://www.voidtools.com/zh-cn/)
- [7-zip](https://www.7-zip.org/download.html)
- [ascadia-code](https://github.com/microsoft/cascadia-code/releases)
- [GifCam](http://blog.bahraniapps.com/gifcam/#download)
- [git-lfs](https://git-lfs.github.com/)
