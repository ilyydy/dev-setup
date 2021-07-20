#! /usr/bin/env bash

[ -n "$DEBUG" ] && set -x
set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASHRC=~/.bashrc
PROFILE=~/.profile

APT_SOURCE=ali-ubuntu-20.04-sources.list # 或 default, ustc-ubuntu-20.04-sources.list
NODE_VERSION=14
NPM_REGISTRY=https://registry.npm.taobao.org # 或 default
PYTHONE_VERSION=3.9.6
PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/ # 或 default, http://mirrors.cloud.tencent.com/pypi/simple, https://pypi.tuna.tsinghua.edu.cn/simple
JAVA_VERSION=14
GOPROXY=https://goproxy.cn # 或 default, https://mirrors.aliyun.com/goproxy/, https://goproxy.io

IFS= read -rsp 'Enter your password: ' password
sudo() {
    command sudo -S "$@" <<<"$password"
}

# 需已安装 jq!!!
getLatestTag() {
    curl --silent "https://api.github.com/repos/${1}/tags" | jq -r '.[0].name'
}

# apt
apt-setup() {
    echo -------------------apt-setup-------------------

    if [ $APT_SOURCE != "default" ]; then
        if [ -f /etc/apt/sources.list ]; then
            sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
        fi

        sudo cp "$SCRIPT_DIR"/lib/"$APT_SOURCE" /etc/apt/sources.list
    fi

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y \
        make \
        tmux \
        zip \
        unzip \
        tree \
        shellcheck \
        jq
}

# git
git-setup() {
    echo -------------------git-setup-------------------
    ## config
    cp "$SCRIPT_DIR"/lib/.gitconfig ~/.gitconfig

    ## git lfs
    ## 需已安装 jq!!!
    tag=$(getLatestTag git-lfs/git-lfs)
    GIT_LFS_DOWNLOAD_FILE=./git-lfs.tar.gz
    curl -L https://github.com/git-lfs/git-lfs/releases/download/"$tag"/git-lfs-linux-amd64-"$tag".tar.gz \
        >$GIT_LFS_DOWNLOAD_FILE
    mkdir -p ./git-lfs
    tar -C ./git-lfs -xzf $GIT_LFS_DOWNLOAD_FILE
    sudo bash ./git-lfs/install.sh
    git lfs install

    rm $GIT_LFS_DOWNLOAD_FILE
    rm -r ./git-lfs
}

# ssh
ssh-setup() {
    echo -------------------ssh-setup-------------------

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    cp "$SCRIPT_DIR"/lib/ssh.config ~/.ssh/config
}

# node.js
node-setup() {
    echo -------------------node-setup-------------------

    ## nvm https://github.com/nvm-sh/nvm
    ## 需已安装 jq!!!
    ## raw.githubusercontent.com 国内无法访问，改用 Github API
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/"$(getLatestTag nvm-sh/nvm)"/install.sh | bash
    curl -s -H "Accept:application/vnd.github.v3.raw" \
        https://api.github.com/repos/nvm-sh/nvm/contents/install.sh?ref="$(getLatestTag nvm-sh/nvm)" | bash

    # shellcheck source=/dev/null
    . ~/.nvm/nvm.sh
    nvm --version

    ## 给 NVM_IOJS_ORG_MIRROR 设置一个不可用的地址，减少不必要的 iojs 查询，加快速度
    NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node NVM_IOJS_ORG_MIRROR='' nvm install $NODE_VERSION

    if [ $NPM_REGISTRY != "default" ]; then
        echo "Set npm registry as $NPM_REGISTRY."
        npm config set registry $NPM_REGISTRY
    fi
}

# python
python-setup() {
    echo -------------------python-setup-------------------

    ## pyenv https://github.com/pyenv/pyenv#installation

    ### install the Python build dependencies
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    cd ~/.pyenv && src/configure && make -C src

    echo -e '\nif shopt -q login_shell; then' \
        '\n  export PYENV_ROOT="$HOME/.pyenv"' \
        '\n  export PATH="$PYENV_ROOT/bin:$PATH"' \
        '\n eval "$(pyenv init --path)"' \
        '\nfi\n' >>$BASHRC
    echo -e '\nif [ -z "$BASH_VERSION" ]; then' \
        '\n  export PYENV_ROOT="$HOME/.pyenv"' \
        '\n  export PATH="$PYENV_ROOT/bin:$PATH"' \
        '\n  eval "$(pyenv init --path)"' \
        '\nfi\n' >>$PROFILE
    echo -e '\neval "$(pyenv init -)"\n' >>$BASHRC

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"

    mkdir -p ~/.pyenv/cache

    curl -L https://npm.taobao.org/mirrors/python/$PYTHONE_VERSION/Python-$PYTHONE_VERSION.tar.xz \
        >~/.pyenv/cache/Python-$PYTHONE_VERSION.tar.xz
    pyenv install $PYTHONE_VERSION -v
    pyenv global $PYTHONE_VERSION

    ## pip
    mkdir -p ~/.pip

    if [ $PIP_INDEX_URL != "default" ]; then
        echo "Set pip index-url as $PIP_INDEX_URL."
        pip config set global.index-url $PIP_INDEX_URL
        echo -e "\nexport PIPENV_PYPI_MIRROR=$PIP_INDEX_URL\n" >>$BASHRC
    fi

    ## pipenv https://pipenv.pypa.io/en/latest/install/#pragmatic-installation-of-pipenv
    pip install --user pipenv
}

# java
java-setup() {
    echo -------------------java-setup-------------------

    sudo apt install -y openjdk-$JAVA_VERSION-jdk

    JAVA_ENV="JAVA_HOME="/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64/bin/""
    sudo bash -c "echo -e '\n$JAVA_ENV\n' >> /etc/environment"

    # shellcheck source=/dev/null
    source /etc/environment
}

# go
go-setup() {
    echo -------------------go-setup-------------------

    ## https://golang.org/dl/
    ## 安装最新版
    GO_DOWNLOAD_FILE=~/go.linux-amd64.tar.gz
    curl -L https://golang.google.cn/dl/"$(curl https://golang.google.cn/VERSION?m=text)".linux-amd64.tar.gz \
        --output $GO_DOWNLOAD_FILE
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $GO_DOWNLOAD_FILE

    ## \$PATH 意味着当作字面量处理，而不是展开 $PATH 变量
    echo -e "\nexport PATH=\$PATH:/usr/local/go/bin\n" >>$PROFILE
    echo -e "\nexport GO111MODULE=on\n" >>$PROFILE

    export PATH=$PATH:/usr/local/go/bin
    go version

    ## GOPROXY
    if [ $GOPROXY != "default" ]; then
        echo "Set GOPROXY as $GOPROXY."
        echo -e "\nexport GOPROXY=$GOPROXY,direct\n" >>$PROFILE
    fi
    # shellcheck source=/dev/null
    source $PROFILE

    rm $GO_DOWNLOAD_FILE
}

# 其他
other-setup() {
    echo -------------------other-setup-------------------

    ## tool.sh
    cp "$SCRIPT_DIR"/lib/tool.sh ~/
    echo -e "\n. ~/tool.sh\n" >>$BASHRC

    mkdir -p ~/repo/ilyydy ~/repo/test ~/repo/learn
}

# wsl 配置
wsl-setup() {
    echo -------------------wsl-setup-------------------

    ## 检查是否是 wsl
    is_in_wsl=false
    if grep -iqF microsoft /proc/sys/kernel/osrelease; then
        echo "It's in wsl!"
        is_in_wsl=true
    fi

    if [ $is_in_wsl = true ]; then
        ## ssh-agent
        cat "$SCRIPT_DIR"/lib/ssh-agent.sh >>$BASHRC

        ## set-the-shells-title as Ubuntu 20-1
        cat "$SCRIPT_DIR"/lib/set-title.sh >>$BASHRC

        ## ssh key
        mkdir -p ~/.ssh
        cd ~/.ssh
        /mnt/c/WINDOWS/explorer.exe . || true
        cd ../

        echo -n "将公私钥复制到打开的 .ssh 文件夹，按任何键继续"
        read -r input
        if compgen -G ~/.ssh/*_rsa* >/dev/null; then
            sudo chown "$USER":"$USER" ~/.ssh/*_rsa*
            chmod 600 ~/.ssh/*_rsa
        fi
    fi
}

main() {
    apt-setup
    git-setup # jq 需已安装!!!
    ssh-setup
    node-setup # jq 需已安装!!!
    python-setup
    java-setup
    go-setup # 安装最新版
    other-setup
    wsl-setup
}

main
