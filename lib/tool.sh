#! /usr/bin/env bash

win-ip() {
    grep nameserver </etc/resolv.conf | awk '{ print $2 }'
}

ssh-Add() {
    local priKey=${1:-id_rsa}
    ssh-add ~/.ssh/"$priKey"
}

ssh-genPub() {
    local pri=${1:?"Please provide private key path."}
    local pub=${2:?"Please provide public key output path."}
    ssh-keygen -y -f "$pri" >"$pub"
}

docker-rmAll() {
    docker rm -f "$(docker ps -a -q)"
}

docker-rmImage() {
    local pattern=${1:?"Please provide a pattern."}
    docker images | grep "$pattern" | awk '{print $1":"$2}' | xargs docker rmi
}

docker-zip() {
    local image=${1:?"Please provide a image name."}
    local outPath=${2:?"Please provide a out path."}
    docker save "$image" | zip "$outPath" -
}

zip-docker() {
    local filePath=${2:?"Please provide a input zip file path."}
    unzip -p "$filePath" | docker load
}

port-use() {
    local port=${1:?"Please provide a port."}
    lsof -i :"$port"
}

git-sId() {
    git rev-parse --short HEAD
}

git-lId() {
    git rev-parse HEAD
}

git-findBrWithCommit() {
    local commit=${1:?"Please provide a commit."}
    git branch -a --contains "$commit"
}

git-fetch() {
    local br=${1:?"Please provide a branch name."}
    git fetch origin "$br":"$br"
}

git-merge() {
    local br1=${1:?"Please provide a branch name."}
    local br2=${1:?"Please provide a branch name."}
    git fetch . "$br1":"$br2"
}

source /usr/share/bash-completion/completions/git
__git_complete git-fetch __git_complete_refs
__git_complete git-merge __git_complete_refs

curl-postJson() {
    local d=${1:?"Please provide json body."}
    local u=${2:?"Please provide url."}
    curl -H "Content-Type:application/json" -X POST --data "$d" "$u"
}
