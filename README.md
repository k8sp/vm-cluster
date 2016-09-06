## vm-cluster自动化安装k8s
### 环境准备

| 虚拟机        | 角色       　|网络组成　|
| ------------- |:-------------:| ----:|
| bootstrapper  | dnsmasq(dhcp,dns),cloudconfig server,boorstrapper server,registry|eth0 nat网络,eth1内部网络 |
| master        | k8s master      |eth0 内部网络|
| worker        | k8s worker     |eth0 内部网络|
### 操作步骤
１．修改vagrantfile中cluster-desc配置,如果仅仅测试使用，保持默认即可
```
cat << EOF > /root/auto-install/cloud-config-server/template/unisound-ailab/build_config.yml 
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


ssh_key=`cat ~/.ssh/authorized_keys` 
sed -i -e 's#<SSH_KEY>#'"$ssh_key"'#' /root/auto-install/cloud-config-server/template/unisound-ailab/build_config.yml

```

２．启动bootstrapper
```
cd vm-cluster
vagrant　bootstrapper
```
* 默认启动时会从github下载bootstrapper源码
* 执行bsroot.sh脚本(下载pxe镜像,生成pxe的配置，dns dhcp配置，registry配置,配置cloudconfig server环境,下载k8s依赖镜像）
* 生成ca证书
* 根据Dockerfile生成bootstrapper镜像
* 启动bootstrapper容器（启动dns，dhcp,docker registry,cloudconfig server）

３．启动k8s master，安装k8s master节点
```
cd vm-cluster
vagrant　master
```
启动的过程成会弹出virtualbox窗口，在窗口中会出现如下提示：
```
Press F8 for menu.(59)
```
按F8后,会出现从网络安装CoreOS的提示如下提示：
```
Install CoreOS from network server
```
直接按enter，然后开始从pxe server加载coreos镜像    
注意：coreos首次仅仅是内存安装，可以通过jounalctl -xef 查看系统日志，当提示coreos硬盘安装成功后系统会重启。
重启后，coreos虚拟机会根据cloudconfig配置文件自动化安装k8s

几分钟后，可以通过docker ps查看k8s master是否启动成功

４．安装k8s worker节点参考master节点安装步骤

###troubleshooting
问题１：
```
Stderr: VBoxManage: error: Implementation of the USB 2.0 controller not found!
```
解决办法：
```
To fix this problem, install the 'Oracle VM VirtualBox Extension Pack'
```
问题２：
```
Error response from daemon: client is newer than server (client API version: 1.23, server API version: 1.22)
```
解决办法：
修改Dockerfile，添加如何参数,　指定docker api的版本为1.22,可以解决版本不一致的问题
```
ENV DOCKER_API_VERSION=1.22
```
问题３：    
无法找到pxe server    
解决办法：
删除dnsmasq.conf中如下两行
```
 interface=eth0
 bind-interfaces

```
