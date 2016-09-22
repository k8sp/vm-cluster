#/bin/bash!

#将boostrapper 代码下载到本地
git clone --quiet https://github.com/k8sp/sextant.git || { echo "Failed git clone sextant"; exit 1; }

#准备bootstrapper安装环境
./sextant/bsroot.sh cluster-desc.yml.template

#修复docker api client 和server 版本不一致的问题
sed -i '/FROM golang:alpine/a\ENV DOCKER_API_VERSION=1.22' ./sextant/Dockerfile

