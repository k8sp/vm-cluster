#!/bin/bash

#生成ssh key
rm -rf /root/.ssh/
/usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -P ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

#将boostrapper 代码下载到本地
cd /root
git clone https://github.com/k8sp/sextant.git
cd sextant

#修改cluster-desc.yml配置文件
mkdir -p /root/sextant/cloud-config-server/template/unisound-ailab
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

#设置bootstrapper免密码登陆其他虚拟机
ssh_key=`cat /root/.ssh/authorized_keys` 
sed -i -e 's#<SSH_KEY>#'"$ssh_key"'#' /root/sextant/cloud-config-server/template/unisound-ailab/build_config.yml

#准备bootstrapper安装环境
./bsroot.sh


#生成ca证书，docker registry　tls证书
cd /bsroot/tls
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
openssl genrsa -out bootstrapper.key 2048
openssl req -new -key bootstrapper.key -out bootstrapper.csr -subj "/CN=bootstrapper"
openssl x509 -req -in bootstrapper.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out bootstrapper.crt -days 365

mkdir -p /etc/docker/certs.d/192.168.8.101:5000
cp ca.pem /etc/docker/certs.d/192.168.8.101:5000/ca.crt
systemctl deamon-reload
systemctl restart docker

#修复无法找到pxe　server的异常
sed -i '/interface=eth0/,/bind-interfaces/d' /bsroot/config/dnsmasq.conf

#修复docker api client 和server 版本不一致的问题
cd /root/sextant
sed -i '/FROM golang:alpine/a\ENV DOCKER_API_VERSION=1.22' ./Dockerfile

#配置docker registry tls证书
sed -i '/FROM golang:alpine/a\ENV REGISTRY_HTTP_TLS_KEY="/bsroot/tls/bootstrapper.key"' ./Dockerfile
sed -i '/FROM golang:alpine/a\ENV REGISTRY_HTTP_TLS_CERTIFICATE="/bsroot/tls/bootstrapper.crt"' ./Dockerfile

#根据Dockerfile build bootstrapper镜像
docker build -t bootstrapper .

#启动dnsmasq,cloudconfig server,docker registry
docker run -d --net=host \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /bsroot:/bsroot \
  bootstrapper

