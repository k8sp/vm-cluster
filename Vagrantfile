Vagrant.configure("2") do |config|

   config.vm.provision "shell", inline: <<-SHELL
     echo '192.168.8.101 bootstrapper' >> /etc/hosts
   SHELL

#定义boostrapper虚拟机
  config.vm.define "bootstrapper" do |bs|
    bs.vm.box = "coreos-stable"
    bs.vm.box_url = "https://storage.googleapis.com/stable.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % [$update_channel, $image_version]
    bs.vm.hostname = "bootstrapper"
    bs.vm.network "private_network", ip: "192.168.8.101",virtualbox__intnet: true
    bs.vm.provision "shell", inline: <<-SHELL
#设置ssh免密码登陆
rm -rf ~/.ssh/
/usr/bin/ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#设置docker registry免tls验证
mkdir -p /etc/systemd/system/docker.service.d/
cat << EOF > /etc/systemd/system/docker.service.d/50-insecure-registry.conf
[Service]
Environment=DOCKER_OPTS='--insecure-registry="bootstrapper:5000"'
EOF
systemctl daemon-reload
systemctl start docker

#将boostrapper 代码下载到本地
cd ~
git clone https://github.com/k8sp/auto-install.git
cd auto-install

#修改cluster-desc.yml配置文件
mkdir -p /root/auto-install/cloud-config-server/template/unisound-ailab
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

./bsroot.sh


cd /bsroot/tls
rm -rf *
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

#修复无法找到pxe　server的异常
sed -i '/interface=eth0/,/bind-interfaces/d' /bsroot/config/dnsmasq.conf
#修复docker api client 和server 版本不一致的问题
cd ~/auto-install
sed -i '/FROM golang:alpine/a\ENV DOCKER_API_VERSION=1.22' ./Dockerfile
docker build -t bootstrapper .
docker run -d --net=host \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /bsroot:/bsroot \
  bootstrapper

  SHELL


    bs.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "2048"
    end
  end

# 定义k8s master虚拟机
    config.vm.define "master" do |master|
      master.vm.box ="c33s/empty"
      master.ssh.insert_key = false
      master.vm.network  "private_network", type: "dhcp", virtualbox__intnet: true, :mac => "0800274a2da1", :adapter=>1, auto_config: false
      master.vm.provider "virtualbox" do |ms|
         ms.check_guest_additions = false
         ms.functional_vboxsf = false
         ms.gui = true
    	 ms.memory = "1024"
    	 ms.customize ["modifyvm", :id, "--boot1", "disk", "--boot2", "net"]
      end
    end

#定义worker虚拟机
    config.vm.define "worker" do |worker|
      worker.vm.box ="c33s/empty"
      worker.ssh.insert_key = false
      worker.vm.network  "private_network", type: "dhcp", virtualbox__intnet: true, :adapter=>1, auto_config: false
      worker.vm.provider "virtualbox" do |wk|
         wk.gui = true
         wk.memory = "1024"
         wk.customize ["modifyvm", :id, "--boot1", "disk", "--boot2", "net"]
      end
    end

end
