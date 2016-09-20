#/bin/bash!

#将boostrapper 代码下载到本地
cd /root
git clone --quiet https://github.com/k8sp/sextant.git
echo "git clone sextant success!"
cd sextant

#修改cluster-desc.yml配置文件
cat << EOF > /root/sextant/cloud-config-server/template/unisound-ailab/build_config.yml 
bootstrapper: 192.168.8.101
subnet: 192.168.8.0
netmask: 255.255.255.0
iplow: 192.168.8.201
iphigh: 192.168.8.220
routers: [192.168.8.101]
broadcast: 192.168.8.255
nameservers: [192.168.8.101, 8.8.8.8, 8.8.4.4]
domainname: "192.168.8.101"
dockerdomain: "bootstrapper"

nodes:
  - mac: "08:00:27:4a:2d:a1"
    ceph_monitor: n
    kube_master: y
    etcd_member: y

ssh_authorized_keys: |1+
    - "<SSH_KEY>"
EOF

#准备bootstrapper安装环境
cd /root/sextant
./bsroot.sh

#修复docker api client 和server 版本不一致的问题
sed -i '/FROM golang:alpine/a\ENV DOCKER_API_VERSION=1.22' ./Dockerfile

#根据Dockerfile build bootstrapper镜像
docker build -t bootstrapper .
docker save bootstrapper:latest >/bsroot/bootstrapper.tar
