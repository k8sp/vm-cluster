# vm-cluster自动化安装k8s


##troubleshooting
问题１：
```
Stderr: VBoxManage: error: Implementation of the USB 2.0 controller not found!
```
解决办法：
```
To fix this problem, either install the 'Oracle VM VirtualBox Extension Pack'
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
删除dnsmasq.conf中如下三行
```
 interface=eth0
 bind-interfaces
 domain=k8s.baifendian.com

```
